import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:smartscan/core/storage/file_storage_service.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:uuid/uuid.dart';

class ScanningService implements ScanPipeline {
  ScanningService(this._storageService);

  final FileStorageService _storageService;
  final _uuid = const Uuid();

  static const int _stabilityWindow = 6;
  static const double _lockConfidenceThreshold = 0.72;
  static const double _lockMovementThreshold = 0.018;
  static const int _autoCaptureDelayMs = 300;

  final List<_DetectionSnapshot> _history = <_DetectionSnapshot>[];
  int? _lockedSinceMs;

  @override
  Future<FrameAnalysisResult> analyzePreviewFrame(
      PreviewFrameInput input) async {
    final detected = _detectRectanglesInLuma(
      lumaBytes: input.lumaBytes,
      width: input.width,
      height: input.height,
      bytesPerRow: input.bytesPerRow,
    );

    final nowMs = input.timestampMs;
    final confidence = detected.isEmpty ? 0.0 : detected.first.confidence;

    _history.add(_DetectionSnapshot(rectangles: detected));
    if (_history.length > _stabilityWindow) {
      _history.removeAt(0);
    }

    final stability = _computeStability(_history);
    final locked = detected.isNotEmpty &&
        confidence >= _lockConfidenceThreshold &&
        stability >= (1.0 - _lockMovementThreshold);

    if (locked) {
      _lockedSinceMs ??= nowMs;
    } else {
      _lockedSinceMs = null;
    }

    final shouldAutoCapture = locked &&
        _lockedSinceMs != null &&
        (nowMs - _lockedSinceMs!) >= _autoCaptureDelayMs;

    final status = detected.isEmpty
        ? DetectionStatus.notDetected
        : locked
            ? DetectionStatus.locked
            : DetectionStatus.adjusting;

    return FrameAnalysisResult(
      detectedRectangles: detected,
      status: status,
      confidence: confidence,
      stability: stability,
      shouldAutoCapture: shouldAutoCapture,
    );
  }

  @override
  Future<ScanPipelineOutput> process(ScanPipelineInput input) async {
    final rectangleMaps = input.detectedRectangles
        .where((rectangle) => rectangle.corners.length == 4)
        .map(_sanitizeRectangle)
        .take(2)
        .toList(growable: false)
        .asMap()
        .entries
        .map(
          (entry) => <String, Object>{
            'label': entry.value.label.isEmpty
                ? 'Page ${entry.key + 1}'
                : entry.value.label,
            'corners': entry.value.corners
                .map((corner) => <double>[corner.x, corner.y])
                .toList(growable: false),
          },
        )
        .toList(growable: false);

    final processedPages = await Isolate.run(
      () => _processCapturePayload(
        <String, Object>{
          'jpeg': input.jpegBytes,
          'rectangles': rectangleMaps,
        },
      ),
    );

    final pages = <ScannedPage>[];
    for (final processedPage in processedPages) {
      final rawJpegBytes = processedPage['rawJpegBytes'] as Uint8List;
      final processedJpegBytes =
          processedPage['processedJpegBytes'] as Uint8List;
      final thumbnailJpegBytes =
          processedPage['thumbnailJpegBytes'] as Uint8List;
      final width = processedPage['width'] as int;
      final height = processedPage['height'] as int;
      final label = processedPage['label'] as String;

      final pageId = _uuid.v4();
      final rawFile = await _storageService.pageFile(
        input.documentId,
        pageId,
        processed: false,
      );
      final processedFile = await _storageService.pageFile(
        input.documentId,
        pageId,
        processed: true,
      );

      await _storageService.writeEncrypted(rawFile, rawJpegBytes);
      await _storageService.writeEncrypted(
        processedFile,
        processedJpegBytes,
      );

      pages.add(
        ScannedPage(
          rawImagePath: rawFile.path,
          processedImagePath: processedFile.path,
          width: width,
          height: height,
          label: label,
          thumbnailJpegBytes: thumbnailJpegBytes,
        ),
      );
    }

    return ScanPipelineOutput(pages: pages);
  }

  DetectedRectangle _sanitizeRectangle(DetectedRectangle rectangle) {
    final corners = rectangle.corners
        .map(
          (corner) => NormalizedCorner(
            corner.x.clamp(0.0, 1.0),
            corner.y.clamp(0.0, 1.0),
          ),
        )
        .toList(growable: false);
    return DetectedRectangle(
      corners: corners,
      confidence: rectangle.confidence.clamp(0.0, 1.0),
      areaRatio: rectangle.areaRatio.clamp(0.0, 1.0),
      label: rectangle.label,
    );
  }

  double _computeStability(List<_DetectionSnapshot> history) {
    if (history.length < _stabilityWindow) {
      return 0.0;
    }

    final baseline = history.first.rectangles;
    if (baseline.isEmpty) {
      return 0.0;
    }

    var maxMovement = 0.0;
    for (var i = 1; i < history.length; i++) {
      final current = history[i].rectangles;
      if (current.isEmpty ||
          current.first.corners.length != baseline.first.corners.length) {
        return 0.0;
      }

      for (var cornerIndex = 0;
          cornerIndex < baseline.first.corners.length;
          cornerIndex++) {
        final dx = (current.first.corners[cornerIndex].x -
                baseline.first.corners[cornerIndex].x)
            .abs();
        final dy = (current.first.corners[cornerIndex].y -
                baseline.first.corners[cornerIndex].y)
            .abs();
        final movement = math.sqrt(dx * dx + dy * dy);
        if (movement > maxMovement) {
          maxMovement = movement;
        }
      }
    }

    return (1.0 - maxMovement).clamp(0.0, 1.0);
  }

  static img.Image _enhanceInIsolate(img.Image image) {
    var processed = img.adjustColor(image, saturation: 0.05, contrast: 1.18);
    processed = img.gaussianBlur(processed, radius: 1);
    return processed;
  }

  static List<Map<String, Object>> _processCapturePayload(
      Map<String, Object> payload) {
    final jpegBytes = payload['jpeg'] as Uint8List;
    final rectangleMaps = payload['rectangles'] as List<Object>;

    final image = img.decodeJpg(jpegBytes);
    if (image == null) {
      throw StateError('Invalid JPEG input');
    }

    final rectangles = rectangleMaps.isEmpty
        ? _detectRectanglesFromImage(image)
        : _decodeRectanglesFromPayload(rectangleMaps);

    final effectiveRectangles = rectangles.isEmpty
        ? const <DetectedRectangle>[
            DetectedRectangle(
              corners: [
                NormalizedCorner(0, 0),
                NormalizedCorner(1, 0),
                NormalizedCorner(1, 1),
                NormalizedCorner(0, 1),
              ],
              confidence: 0.5,
              areaRatio: 1.0,
              label: 'Page 1',
            )
          ]
        : rectangles.take(2).toList(growable: false);

    return effectiveRectangles.map((rectangle) {
      final crop = _extractRectangleCropStatic(image, rectangle);
      final enhanced = _enhanceInIsolate(crop);
      final thumbnail = img.copyResize(
        enhanced,
        width: 240,
        interpolation: img.Interpolation.average,
      );

      return <String, Object>{
        'rawJpegBytes': Uint8List.fromList(img.encodeJpg(crop, quality: 95)),
        'processedJpegBytes':
            Uint8List.fromList(img.encodeJpg(enhanced, quality: 92)),
        'thumbnailJpegBytes':
            Uint8List.fromList(img.encodeJpg(thumbnail, quality: 72)),
        'width': enhanced.width,
        'height': enhanced.height,
        'label': rectangle.label,
      };
    }).toList(growable: false);
  }

  static List<DetectedRectangle> _detectRectanglesFromImage(img.Image image) {
    final gray = img.grayscale(image);
    final lumaBytes = Uint8List(gray.width * gray.height);

    var offset = 0;
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        lumaBytes[offset++] = gray.getPixel(x, y).r.toInt();
      }
    }

    return _detectRectanglesInLuma(
      lumaBytes: lumaBytes,
      width: gray.width,
      height: gray.height,
      bytesPerRow: gray.width,
    );
  }

  static List<DetectedRectangle> _decodeRectanglesFromPayload(
    List<Object> rectangleMaps,
  ) {
    try {
      return rectangleMaps
          .map((entry) {
            final map = entry as Map<Object?, Object?>;
            final label = (map['label'] ?? '').toString();
            final cornersRaw =
                (map['corners'] as List<Object?>?) ?? const <Object?>[];

            final corners = cornersRaw.map((corner) {
              final point = corner as List<Object?>;
              final x = (point[0] as num).toDouble();
              final y = (point[1] as num).toDouble();
              return NormalizedCorner(x, y);
            }).toList(growable: false);

            return DetectedRectangle(
              corners: corners,
              confidence: 1.0,
              areaRatio: 1.0,
              label: label,
            );
          })
          .where((rectangle) => rectangle.corners.length == 4)
          .toList(growable: false);
    } catch (_) {
      return const <DetectedRectangle>[];
    }
  }

  static img.Image _extractRectangleCropStatic(
    img.Image source,
    DetectedRectangle rectangle,
  ) {
    if (rectangle.corners.length != 4) {
      return source;
    }

    final points = rectangle.corners
        .map((c) => math.Point<double>(c.x * source.width, c.y * source.height))
        .toList(growable: false);

    points.sort((a, b) => a.y.compareTo(b.y));
    final top = [points[0], points[1]]..sort((a, b) => a.x.compareTo(b.x));
    final bottom = [points[2], points[3]]..sort((a, b) => a.x.compareTo(b.x));

    final tl = top[0];
    final tr = top[1];
    final bl = bottom[0];
    final br = bottom[1];

    final widthTop = math.sqrt(math.pow(tr.x - tl.x, 2) + math.pow(tr.y - tl.y, 2));
    final widthBottom = math.sqrt(math.pow(br.x - bl.x, 2) + math.pow(br.y - bl.y, 2));
    final destWidth = math.max(widthTop, widthBottom).toInt();

    final heightLeft = math.sqrt(math.pow(bl.x - tl.x, 2) + math.pow(bl.y - tl.y, 2));
    final heightRight = math.sqrt(math.pow(br.x - tr.x, 2) + math.pow(br.y - tr.y, 2));
    final destHeight = math.max(heightLeft, heightRight).toInt();

    if (destWidth <= 10 || destHeight <= 10) {
      return img.copyCrop(
        source, 
        x: 0, 
        y: 0, 
        width: source.width, 
        height: source.height
      );
    }

    final output = img.Image(
        width: destWidth, 
        height: destHeight, 
        numChannels: source.numChannels
    );

    for (var y = 0; y < destHeight; y++) {
      final v = y / destHeight;
      for (var x = 0; x < destWidth; x++) {
        final u = x / destWidth;

        // Inverse bilinear projection (FR-01.2) mapping flat rect back to skewed quad
        final srcX = (1 - u) * (1 - v) * tl.x +
                     u * (1 - v) * tr.x +
                     u * v * br.x +
                     (1 - u) * v * bl.x;

        final srcY = (1 - u) * (1 - v) * tl.y +
                     u * (1 - v) * tr.y +
                     u * v * br.y +
                     (1 - u) * v * bl.y;

        final px = srcX.clamp(0.0, source.width - 1.0).toInt();
        final py = srcY.clamp(0.0, source.height - 1.0).toInt();

        output.setPixel(x, y, source.getPixel(px, py));
      }
    }

    return output;
  }

  static List<DetectedRectangle> _detectRectanglesInLuma({
    required Uint8List lumaBytes,
    required int width,
    required int height,
    required int bytesPerRow,
  }) {
    if (width < 16 || height < 16) {
      return const <DetectedRectangle>[];
    }

    final edgeDetected = _detectWithEdgeProjection(
      lumaBytes: lumaBytes,
      width: width,
      height: height,
      bytesPerRow: bytesPerRow,
    );
    if (edgeDetected.isNotEmpty) {
      return edgeDetected;
    }

    final scale = math.max(width, height) / 280.0;
    final sampleStep = math.max(1, scale.ceil());
    final sampledWidth = (width / sampleStep).floor();
    final sampledHeight = (height / sampleStep).floor();

    if (sampledWidth < 8 || sampledHeight < 8) {
      return const <DetectedRectangle>[];
    }

    final luminance = Uint8List(sampledWidth * sampledHeight);
    var sum = 0;
    for (var y = 0; y < sampledHeight; y++) {
      for (var x = 0; x < sampledWidth; x++) {
        final srcX = x * sampleStep;
        final srcY = y * sampleStep;
        final value = lumaBytes[srcY * bytesPerRow + srcX];
        luminance[y * sampledWidth + x] = value;
        sum += value;
      }
    }

    final mean = sum / luminance.length;
    final threshold = (mean + 10.0).clamp(80.0, 220.0).toInt();

    final binary = Uint8List(luminance.length);
    for (var i = 0; i < luminance.length; i++) {
      binary[i] = luminance[i] >= threshold ? 1 : 0;
    }

    final visited = Uint8List(binary.length);
    final candidates = <_ComponentCandidate>[];

    final queueX = List<int>.filled(binary.length, 0);
    final queueY = List<int>.filled(binary.length, 0);

    for (var y = 0; y < sampledHeight; y++) {
      for (var x = 0; x < sampledWidth; x++) {
        final index = y * sampledWidth + x;
        if (binary[index] == 0 || visited[index] == 1) {
          continue;
        }

        var head = 0;
        var tail = 0;
        queueX[tail] = x;
        queueY[tail] = y;
        tail++;
        visited[index] = 1;

        var minX = x;
        var maxX = x;
        var minY = y;
        var maxY = y;
        var area = 0;

        while (head < tail) {
          final cx = queueX[head];
          final cy = queueY[head];
          head++;
          area++;

          if (cx < minX) minX = cx;
          if (cx > maxX) maxX = cx;
          if (cy < minY) minY = cy;
          if (cy > maxY) maxY = cy;

          for (var offsetY = -1; offsetY <= 1; offsetY++) {
            for (var offsetX = -1; offsetX <= 1; offsetX++) {
              if (offsetX == 0 && offsetY == 0) {
                continue;
              }

              final nx = cx + offsetX;
              final ny = cy + offsetY;
              if (nx < 0 ||
                  ny < 0 ||
                  nx >= sampledWidth ||
                  ny >= sampledHeight) {
                continue;
              }

              final neighbor = ny * sampledWidth + nx;
              if (binary[neighbor] == 1 && visited[neighbor] == 0) {
                visited[neighbor] = 1;
                queueX[tail] = nx;
                queueY[tail] = ny;
                tail++;
              }
            }
          }
        }

        final boxWidth = maxX - minX + 1;
        final boxHeight = maxY - minY + 1;
        final boxArea = boxWidth * boxHeight;
        if (boxArea == 0) {
          continue;
        }

        final areaRatio = boxArea / (sampledWidth * sampledHeight);
        final fillRatio = area / boxArea;
        final aspect = boxWidth / boxHeight;

        final aspectScore = 1.0 - ((aspect - 1.0).abs() / 1.8).clamp(0.0, 1.0);
        final confidence = (areaRatio.clamp(0.0, 0.7) / 0.7) * 0.50 +
            fillRatio.clamp(0.0, 1.0) * 0.35 +
            aspectScore * 0.15;

        if (areaRatio < 0.07 || areaRatio > 0.92) {
          continue;
        }
        if (fillRatio < 0.45) {
          continue;
        }
        if (aspect < 0.5 || aspect > 2.1) {
          continue;
        }

        candidates.add(
          _ComponentCandidate(
            minX: minX,
            minY: minY,
            maxX: maxX,
            maxY: maxY,
            areaRatio: areaRatio,
            confidence: confidence.clamp(0.0, 1.0),
          ),
        );
      }
    }

    candidates.sort((a, b) {
      final lhs = b.confidence * b.areaRatio;
      final rhs = a.confidence * a.areaRatio;
      return lhs.compareTo(rhs);
    });

    final selected = <_ComponentCandidate>[];
    for (final candidate in candidates) {
      final overlaps = selected
          .any((existing) => _intersectionOverUnion(candidate, existing) > 0.7);
      if (!overlaps) {
        selected.add(candidate);
      }
      if (selected.length == 2) {
        break;
      }
    }

    selected.sort((a, b) {
      final centerAx = (a.minX + a.maxX) / 2;
      final centerAy = (a.minY + a.maxY) / 2;
      final centerBx = (b.minX + b.maxX) / 2;
      final centerBy = (b.minY + b.maxY) / 2;
      final dx = (centerAx - centerBx).abs();
      final dy = (centerAy - centerBy).abs();
      if (dx >= dy) {
        return centerAx.compareTo(centerBx);
      }
      return centerAy.compareTo(centerBy);
    });

    return List<DetectedRectangle>.generate(selected.length, (index) {
      final candidate = selected[index];
      final minX = candidate.minX / sampledWidth;
      final maxX = candidate.maxX / sampledWidth;
      final minY = candidate.minY / sampledHeight;
      final maxY = candidate.maxY / sampledHeight;

      return DetectedRectangle(
        corners: [
          NormalizedCorner(minX, minY),
          NormalizedCorner(maxX, minY),
          NormalizedCorner(maxX, maxY),
          NormalizedCorner(minX, maxY),
        ],
        confidence: candidate.confidence,
        areaRatio: candidate.areaRatio,
        label: 'Page ${index + 1}',
      );
    });
  }

  static List<DetectedRectangle> _detectWithEdgeProjection({
    required Uint8List lumaBytes,
    required int width,
    required int height,
    required int bytesPerRow,
  }) {
    final scale = math.max(width, height) / 320.0;
    final sampleStep = math.max(1, scale.ceil());
    final sampledWidth = (width / sampleStep).floor();
    final sampledHeight = (height / sampleStep).floor();

    if (sampledWidth < 20 || sampledHeight < 20) {
      return const <DetectedRectangle>[];
    }

    final luminance = Uint8List(sampledWidth * sampledHeight);
    var offset = 0;
    for (var y = 0; y < sampledHeight; y++) {
      for (var x = 0; x < sampledWidth; x++) {
        final srcX = x * sampleStep;
        final srcY = y * sampleStep;
        luminance[offset++] = lumaBytes[srcY * bytesPerRow + srcX];
      }
    }

    final verticalScore = List<double>.filled(sampledWidth, 0.0);
    final horizontalScore = List<double>.filled(sampledHeight, 0.0);

    for (var y = 1; y < sampledHeight - 1; y++) {
      for (var x = 1; x < sampledWidth - 1; x++) {
        final index = y * sampledWidth + x;
        final gx = (luminance[index + 1] - luminance[index - 1]).abs();
        final gy =
            (luminance[index + sampledWidth] - luminance[index - sampledWidth])
                .abs();
        final gradient = (gx + gy).toDouble();
        verticalScore[x] += gradient;
        horizontalScore[y] += gradient;
      }
    }

    final smoothVertical = _smooth1D(verticalScore, radius: 3);
    final smoothHorizontal = _smooth1D(horizontalScore, radius: 3);

    final left = _findPeak(
      smoothVertical,
      start: sampledWidth ~/ 16,
      end: sampledWidth ~/ 2,
    );
    final right = _findPeak(
      smoothVertical,
      start: sampledWidth ~/ 2,
      end: sampledWidth - sampledWidth ~/ 16,
    );
    final top = _findPeak(
      smoothHorizontal,
      start: sampledHeight ~/ 16,
      end: sampledHeight ~/ 2,
    );
    final bottom = _findPeak(
      smoothHorizontal,
      start: sampledHeight ~/ 2,
      end: sampledHeight - sampledHeight ~/ 16,
    );

    if (left == null || right == null || top == null || bottom == null) {
      return const <DetectedRectangle>[];
    }

    final boxWidth = right - left;
    final boxHeight = bottom - top;
    if (boxWidth < sampledWidth * 0.28 || boxHeight < sampledHeight * 0.28) {
      return const <DetectedRectangle>[];
    }

    final areaRatio = (boxWidth * boxHeight) / (sampledWidth * sampledHeight);
    if (areaRatio < 0.12 || areaRatio > 0.95) {
      return const <DetectedRectangle>[];
    }

    final edgeEnergy = smoothVertical[left] +
        smoothVertical[right] +
        smoothHorizontal[top] +
        smoothHorizontal[bottom];
    final maxVertical = smoothVertical.reduce(math.max);
    final maxHorizontal = smoothHorizontal.reduce(math.max);
    final normalizedEnergy =
        edgeEnergy / ((maxVertical * 2) + (maxHorizontal * 2) + 1e-6);
    final confidence =
        (0.55 * areaRatio.clamp(0.0, 1.0) + 0.45 * normalizedEnergy)
            .clamp(0.0, 1.0);

    final minX = (left / sampledWidth).clamp(0.0, 1.0);
    final maxX = (right / sampledWidth).clamp(0.0, 1.0);
    final minY = (top / sampledHeight).clamp(0.0, 1.0);
    final maxY = (bottom / sampledHeight).clamp(0.0, 1.0);

    return <DetectedRectangle>[
      DetectedRectangle(
        corners: [
          NormalizedCorner(minX, minY),
          NormalizedCorner(maxX, minY),
          NormalizedCorner(maxX, maxY),
          NormalizedCorner(minX, maxY),
        ],
        confidence: confidence,
        areaRatio: areaRatio,
        label: 'Page 1',
      ),
    ];
  }

  static List<double> _smooth1D(List<double> input, {required int radius}) {
    final output = List<double>.filled(input.length, 0.0);
    for (var i = 0; i < input.length; i++) {
      var sum = 0.0;
      var count = 0;
      for (var j = math.max(0, i - radius);
          j <= math.min(input.length - 1, i + radius);
          j++) {
        sum += input[j];
        count++;
      }
      output[i] = count == 0 ? 0.0 : sum / count;
    }
    return output;
  }

  static int? _findPeak(List<double> values,
      {required int start, required int end}) {
    if (start >= end || start < 0 || end > values.length) {
      return null;
    }

    var bestIndex = -1;
    var bestValue = -1.0;
    for (var i = start; i < end; i++) {
      final value = values[i];
      if (value > bestValue) {
        bestValue = value;
        bestIndex = i;
      }
    }

    if (bestIndex < 0) {
      return null;
    }

    final globalMean =
        values.fold<double>(0.0, (sum, value) => sum + value) / values.length;
    if (bestValue < globalMean * 1.15) {
      return null;
    }

    return bestIndex;
  }

  static double _intersectionOverUnion(
      _ComponentCandidate a, _ComponentCandidate b) {
    final left = math.max(a.minX, b.minX);
    final right = math.min(a.maxX, b.maxX);
    final top = math.max(a.minY, b.minY);
    final bottom = math.min(a.maxY, b.maxY);

    if (right <= left || bottom <= top) {
      return 0.0;
    }

    final intersection = (right - left) * (bottom - top);
    final areaA = (a.maxX - a.minX) * (a.maxY - a.minY);
    final areaB = (b.maxX - b.minX) * (b.maxY - b.minY);
    final union = areaA + areaB - intersection;

    if (union <= 0) {
      return 0.0;
    }

    return intersection / union;
  }
}

class _DetectionSnapshot {
  const _DetectionSnapshot({required this.rectangles});

  final List<DetectedRectangle> rectangles;
}

class _ComponentCandidate {
  const _ComponentCandidate({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
    required this.areaRatio,
    required this.confidence,
  });

  final int minX;
  final int minY;
  final int maxX;
  final int maxY;
  final double areaRatio;
  final double confidence;
}
