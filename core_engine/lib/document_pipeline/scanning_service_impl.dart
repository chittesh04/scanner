import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:uuid/uuid.dart';

import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:smartscan_core_engine/ports/secure_storage_port.dart';

/// Document scanning service powered by OpenCV via FFI.
///
/// Uses a **persistent background isolate** for all OpenCV work so that:
/// - The FFI library is loaded exactly once, not per-frame
/// - Frame analysis and capture processing run sequentially without
///   spawning new isolates
/// - The main/UI thread is never blocked by native code
class ScanningServiceImpl implements ScanPipeline {
  ScanningServiceImpl(this._storagePort);

  final SecureStoragePort _storagePort;
  final _uuid = const Uuid();

  // ── Stability / auto-capture tuning ──────────────────────────────────
  static const int _stabilityWindow = 6;
  static const double _lockConfidenceThreshold = 0.72;
  static const double _lockMovementThreshold = 0.018;
  static const int _autoCaptureDelayMs = 300;

  final List<_DetectionSnapshot> _history = <_DetectionSnapshot>[];
  int? _lockedSinceMs;

  // ── Persistent isolate for OpenCV work ────────────────────────────────
  _CvIsolate? _cvIsolate;
  bool _isSpawning = false;

  Future<_CvIsolate> _getIsolate() async {
    if (_cvIsolate != null) return _cvIsolate!;

    // Guard against multiple concurrent spawns.
    if (_isSpawning) {
      // Wait a bit for the other spawn to complete.
      while (_isSpawning) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      if (_cvIsolate != null) return _cvIsolate!;
    }

    _isSpawning = true;
    try {
      _cvIsolate = await _CvIsolate.spawn();
      return _cvIsolate!;
    } finally {
      _isSpawning = false;
    }
  }

  // ── ScanPipeline: analyzePreviewFrame ────────────────────────────────
  @override
  Future<FrameAnalysisResult> analyzePreviewFrame(
      PreviewFrameInput input) async {
    final isolate = await _getIsolate();
    final detected = await isolate.detectEdges(
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

  // ── ScanPipeline: process (capture → warp → threshold → save) ───────
  @override
  Future<ScanPipelineOutput> process(ScanPipelineInput input) async {
    final rectangleMaps = input.detectedRectangles
        .where((r) => r.corners.length == 4)
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
                .map((c) => <double>[c.x, c.y])
                .toList(growable: false),
          },
        )
        .toList(growable: false);

    final isolate = await _getIsolate();
    final processedPages = await isolate.processCapture(<String, Object>{
      'jpeg': input.jpegBytes,
      'rectangles': rectangleMaps,
    });

    final pages = <ScannedPage>[];
    for (final p in processedPages) {
      final rawJpegBytes = p['rawJpegBytes'] as Uint8List;
      final processedJpegBytes = p['processedJpegBytes'] as Uint8List;
      final thumbnailJpegBytes = p['thumbnailJpegBytes'] as Uint8List;
      final width = p['width'] as int;
      final height = p['height'] as int;
      final label = p['label'] as String;

      final pageId = _uuid.v4();
      final rawImagePath = await _storagePort.writeImageBytes(
        input.documentId,
        pageId,
        rawJpegBytes,
        processed: false,
      );
      final processedImagePath = await _storagePort.writeImageBytes(
        input.documentId,
        pageId,
        processedJpegBytes,
        processed: true,
      );

      pages.add(ScannedPage(
        rawImagePath: rawImagePath,
        processedImagePath: processedImagePath,
        width: width,
        height: height,
        label: label,
        thumbnailJpegBytes: thumbnailJpegBytes,
      ));
    }

    return ScanPipelineOutput(pages: pages);
  }

  // ── Helpers ──────────────────────────────────────────────────────────
  DetectedRectangle _sanitizeRectangle(DetectedRectangle rectangle) {
    final corners = rectangle.corners
        .map((c) => NormalizedCorner(
              c.x.clamp(0.0, 1.0),
              c.y.clamp(0.0, 1.0),
            ))
        .toList(growable: false);
    return DetectedRectangle(
      corners: corners,
      confidence: rectangle.confidence.clamp(0.0, 1.0),
      areaRatio: rectangle.areaRatio.clamp(0.0, 1.0),
      label: rectangle.label,
    );
  }

  double _computeStability(List<_DetectionSnapshot> history) {
    if (history.length < _stabilityWindow) return 0.0;
    final baseline = history.first.rectangles;
    if (baseline.isEmpty) return 0.0;

    var maxMovement = 0.0;
    for (var i = 1; i < history.length; i++) {
      final current = history[i].rectangles;
      if (current.isEmpty ||
          current.first.corners.length != baseline.first.corners.length) {
        return 0.0;
      }
      for (var ci = 0; ci < baseline.first.corners.length; ci++) {
        final dx =
            (current.first.corners[ci].x - baseline.first.corners[ci].x).abs();
        final dy =
            (current.first.corners[ci].y - baseline.first.corners[ci].y).abs();
        final movement = math.sqrt(dx * dx + dy * dy);
        if (movement > maxMovement) maxMovement = movement;
      }
    }
    return (1.0 - maxMovement).clamp(0.0, 1.0);
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  Persistent background isolate wrapper
// ═══════════════════════════════════════════════════════════════════════

/// Manages a long-lived isolate that does all OpenCV work.
/// The FFI library loads once when the isolate starts. All subsequent
/// `detectEdges` and `processCapture` calls reuse the same isolate.
class _CvIsolate {
  _CvIsolate._(this._sendPort);

  final SendPort _sendPort;
  int _nextId = 0;
  final _pending = <int, Completer<Object?>>{};

  /// Spawn the persistent isolate and wait for it to send back its SendPort.
  static Future<_CvIsolate> spawn() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateEntry, receivePort.sendPort);

    final completer = Completer<SendPort>();
    late final _CvIsolate instance;

    receivePort.listen((message) {
      if (message is SendPort) {
        instance = _CvIsolate._(message);
        completer.complete(message);
      } else if (message is _IsolateResponse) {
        final pending = instance._pending.remove(message.id);
        if (pending != null) {
          if (message.error != null) {
            pending.completeError(message.error!);
          } else {
            pending.complete(message.result);
          }
        }
      }
    });

    await completer.future;
    return instance;
  }

  /// Send a detect-edges request to the background isolate.
  Future<List<DetectedRectangle>> detectEdges({
    required Uint8List lumaBytes,
    required int width,
    required int height,
    required int bytesPerRow,
  }) async {
    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;

    _sendPort.send(_IsolateRequest(
      id: id,
      type: _RequestType.detectEdges,
      payload: <String, Object>{
        'lumaBytes': lumaBytes,
        'width': width,
        'height': height,
        'bytesPerRow': bytesPerRow,
      },
    ));

    final result = await completer.future;
    return (result as List?)?.cast<DetectedRectangle>() ?? const [];
  }

  /// Send a process-capture request to the background isolate.
  Future<List<Map<String, Object>>> processCapture(
      Map<String, Object> payload) async {
    final id = _nextId++;
    final completer = Completer<Object?>();
    _pending[id] = completer;

    _sendPort.send(_IsolateRequest(
      id: id,
      type: _RequestType.processCapture,
      payload: payload,
    ));

    final result = await completer.future;
    return (result as List?)?.cast<Map<String, Object>>() ?? const [];
  }
}

enum _RequestType { detectEdges, processCapture }

class _IsolateRequest {
  const _IsolateRequest({
    required this.id,
    required this.type,
    required this.payload,
  });
  final int id;
  final _RequestType type;
  final Map<String, Object> payload;
}

class _IsolateResponse {
  const _IsolateResponse({required this.id, this.result, this.error});
  final int id;
  final Object? result;
  final Object? error;
}

/// The entry point that runs inside the persistent isolate.
/// Receives requests, processes them with OpenCV, and sends results back.
void _isolateEntry(SendPort mainSendPort) {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is! _IsolateRequest) return;

    try {
      switch (message.type) {
        case _RequestType.detectEdges:
          final payload = message.payload;
          final result = _detectDocumentEdges(
            lumaBytes: payload['lumaBytes'] as Uint8List,
            width: payload['width'] as int,
            height: payload['height'] as int,
            bytesPerRow: payload['bytesPerRow'] as int,
          );
          mainSendPort.send(
              _IsolateResponse(id: message.id, result: result));

        case _RequestType.processCapture:
          final result = _processCapturePayload(message.payload);
          mainSendPort.send(
              _IsolateResponse(id: message.id, result: result));
      }
    } catch (e) {
      mainSendPort
          .send(_IsolateResponse(id: message.id, error: e.toString()));
    }
  });
}

// ════════════════════════════════════════════════════════════════════
//  Static methods – safe to run in isolate (no instance state)
// ════════════════════════════════════════════════════════════════════

/// Uses OpenCV Gaussian Blur → Canny → findContours → approxPolyDP to
/// locate the largest quadrilateral (document edge) in the luma frame.
List<DetectedRectangle> _detectDocumentEdges({
  required Uint8List lumaBytes,
  required int width,
  required int height,
  required int bytesPerRow,
}) {
  if (width < 16 || height < 16) return const [];

  // Build a continuous grayscale Mat from the luma plane.
  // bytesPerRow may be wider than width (padding), so we copy row-by-row.
  final continuous = Uint8List(width * height);
  for (var y = 0; y < height; y++) {
    final srcOffset = y * bytesPerRow;
    final dstOffset = y * width;
    continuous.setRange(dstOffset, dstOffset + width,
        lumaBytes.buffer.asUint8List(lumaBytes.offsetInBytes + srcOffset, width));
  }
  final gray = cv.Mat.fromList(height, width, cv.MatType.CV_8UC1, continuous);

  // Down-scale for speed (target ~320px on longest side).
  final scale = math.max(width, height) / 320.0;
  final pw = (width / scale).round();
  final ph = (height / scale).round();
  final resized = cv.resize(gray, (pw, ph));

  // Gaussian Blur → Canny
  final blurred = cv.gaussianBlur(resized, (5, 5), 0);
  final edges = cv.canny(blurred, 50, 150);

  // Create a 3x3 structuring element for dilation
  final kernel = cv.getStructuringElement(cv.MORPH_RECT, (3, 3));
  final dilatedEdges = cv.dilate(edges, kernel);

  // Find contours using dilated edges
  final (contours, hierarchy) = cv.findContours(
    dilatedEdges,
    cv.RETR_EXTERNAL,
    cv.CHAIN_APPROX_SIMPLE,
  );

  // Look for the largest quadrilateral
  double maxArea = 0;
  List<cv.Point>? bestQuad;
  final minArea = pw * ph * 0.10; // at least 10 % of frame

  for (final contour in contours) {
    final area = cv.contourArea(contour);
    if (area < minArea) continue;

    final peri = cv.arcLength(contour, true);
    final approx = cv.approxPolyDP(contour, 0.02 * peri, true);

    if (approx.length == 4 && area > maxArea) {
      maxArea = area;
      bestQuad = approx.toList().map((p) => cv.Point(p.x, p.y)).toList(growable: false);
    }

    // CRITICAL: Dispose the temporary native vector immediately
    approx.dispose();
  }

  // CRITICAL: Dispose the main contour vector and hierarchy
  contours.dispose();
  hierarchy.dispose();

  // Dispose new native objects
  kernel.dispose();
  dilatedEdges.dispose();

  // Dispose OpenCV Mats eagerly
  gray.dispose();
  resized.dispose();
  blurred.dispose();
  edges.dispose();

  if (bestQuad == null) return const [];

  // Sort corners: top-left, top-right, bottom-right, bottom-left
  final sorted = _sortCorners(bestQuad);
  final areaRatio = maxArea / (pw * ph);

  return [
    DetectedRectangle(
      corners: [
        NormalizedCorner(sorted[0].x / pw, sorted[0].y / ph),
        NormalizedCorner(sorted[1].x / pw, sorted[1].y / ph),
        NormalizedCorner(sorted[2].x / pw, sorted[2].y / ph),
        NormalizedCorner(sorted[3].x / pw, sorted[3].y / ph),
      ],
      confidence: (0.5 + 0.5 * areaRatio).clamp(0.0, 1.0),
      areaRatio: areaRatio.clamp(0.0, 1.0),
      label: 'Page 1',
    ),
  ];
}

/// Processes a full-resolution capture: perspective warp + adaptive
/// threshold + JPEG encode.
List<Map<String, Object>> _processCapturePayload(
    Map<String, Object> payload) {
  final jpegBytes = payload['jpeg'] as Uint8List;
  final rectangleMaps = payload['rectangles'] as List<Object>;

  final imageMat = cv.imdecode(jpegBytes, cv.IMREAD_COLOR);

  final rectangles = _decodeRectanglesFromPayload(rectangleMaps);
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
          ),
        ]
      : rectangles;

  final results = <Map<String, Object>>[];

  for (final rect in effectiveRectangles) {
    // ── 1. Perspective Warp ──────────────────────────────────────────
    final warped = _warpPerspective(imageMat, rect);

    // ── 2. Adaptive Thresholding ("scanned" B&W look) ───────────────
    final grayWarped = cv.cvtColor(warped, cv.COLOR_BGR2GRAY);

    // Illumination Normalization (Shadow Removal)
    final dilateKernel = cv.getStructuringElement(cv.MORPH_RECT, (35, 35));
    final bgDilated = cv.dilate(grayWarped, dilateKernel);
    final bgMap = cv.medianBlur(bgDilated, 21);
    final diff = cv.subtract(bgMap, grayWarped);
    final normalized = cv.bitwiseNOT(diff);

    // Dynamic Block Size Calculation
    final minDimension = math.min(warped.cols, warped.rows);
    int blockSize = (minDimension * 0.015).toInt();
    if (blockSize % 2 == 0) blockSize++;
    if (blockSize < 3) blockSize = 3;
    const double cValue = 12.0;

    final enhanced = cv.adaptiveThreshold(
      normalized,
      255.0,
      cv.ADAPTIVE_THRESH_GAUSSIAN_C,
      cv.THRESH_BINARY,
      blockSize,
      cValue,
    );

    dilateKernel.dispose();
    bgDilated.dispose();
    bgMap.dispose();
    diff.dispose();
    normalized.dispose();

    // ── 3. Thumbnail ────────────────────────────────────────────────
    final thumbH = enhanced.rows > 0
        ? (240 * enhanced.rows / enhanced.cols).round()
        : 240;
    final thumbnail = cv.resize(enhanced, (240, thumbH));

    // ── 4. JPEG encode ──────────────────────────────────────────────
    final jpegParams = cv.VecI32.fromList(
        [cv.IMWRITE_JPEG_QUALITY, 95]);
    final (_, rawEncoded) = cv.imencode('.jpg', warped, params: jpegParams);
    jpegParams.dispose();

    final procParams = cv.VecI32.fromList(
        [cv.IMWRITE_JPEG_QUALITY, 92]);
    final (_, procEncoded) = cv.imencode('.jpg', enhanced, params: procParams);
    procParams.dispose();

    final thumbParams = cv.VecI32.fromList(
        [cv.IMWRITE_JPEG_QUALITY, 72]);
    final (_, thumbEncoded) =
        cv.imencode('.jpg', thumbnail, params: thumbParams);
    thumbParams.dispose();

    results.add(<String, Object>{
      'rawJpegBytes': Uint8List.fromList(rawEncoded),
      'processedJpegBytes': Uint8List.fromList(procEncoded),
      'thumbnailJpegBytes': Uint8List.fromList(thumbEncoded),
      'width': enhanced.cols,
      'height': enhanced.rows,
      'label': rect.label,
    });

    warped.dispose();
    grayWarped.dispose();
    enhanced.dispose();
    thumbnail.dispose();
  }

  imageMat.dispose();
  return results;
}

/// Uses `getPerspectiveTransform2f` + `warpPerspective` to flatten a
/// detected quadrilateral into a rectangle.
cv.Mat _warpPerspective(cv.Mat source, DetectedRectangle rectangle) {
  if (rectangle.corners.length != 4) return source.clone();

  final w = source.cols.toDouble();
  final h = source.rows.toDouble();

  // Map normalised corners → pixel coordinates
  final pixelPts = rectangle.corners
      .map((c) => cv.Point((c.x * w).round(), (c.y * h).round()))
      .toList();

  // Sort: top-left, top-right, bottom-right, bottom-left
  final sorted = _sortCorners(pixelPts);
  final tl = sorted[0];
  final tr = sorted[1];
  final br = sorted[2];
  final bl = sorted[3];

  final widthTop = math.sqrt(
      math.pow(tr.x - tl.x, 2) + math.pow(tr.y - tl.y, 2));
  final widthBot = math.sqrt(
      math.pow(br.x - bl.x, 2) + math.pow(br.y - bl.y, 2));
  final destW = math.max(widthTop, widthBot).toInt();

  final heightL = math.sqrt(
      math.pow(bl.x - tl.x, 2) + math.pow(bl.y - tl.y, 2));
  final heightR = math.sqrt(
      math.pow(br.x - tr.x, 2) + math.pow(br.y - tr.y, 2));
  final destH = math.max(heightL, heightR).toInt();

  if (destW <= 10 || destH <= 10) return source.clone();

  final srcPts = cv.VecPoint2f.fromList([
    cv.Point2f(tl.x.toDouble(), tl.y.toDouble()),
    cv.Point2f(tr.x.toDouble(), tr.y.toDouble()),
    cv.Point2f(br.x.toDouble(), br.y.toDouble()),
    cv.Point2f(bl.x.toDouble(), bl.y.toDouble()),
  ]);

  final dstPts = cv.VecPoint2f.fromList([
    cv.Point2f(0, 0),
    cv.Point2f(destW.toDouble() - 1, 0),
    cv.Point2f(destW.toDouble() - 1, destH.toDouble() - 1),
    cv.Point2f(0, destH.toDouble() - 1),
  ]);

  final transform = cv.getPerspectiveTransform2f(srcPts, dstPts);
  final warped = cv.warpPerspective(source, transform, (destW, destH));

  srcPts.dispose();
  dstPts.dispose();
  transform.dispose();

  return warped;
}

/// Sort four points into [top-left, top-right, bottom-right, bottom-left].
List<cv.Point> _sortCorners(List<cv.Point> pts) {
  assert(pts.length == 4);
  final sorted = List<cv.Point>.from(pts)
    ..sort((a, b) => a.y.compareTo(b.y));
  final top = [sorted[0], sorted[1]]..sort((a, b) => a.x.compareTo(b.x));
  final bottom = [sorted[2], sorted[3]]..sort((a, b) => a.x.compareTo(b.x));
  return [top[0], top[1], bottom[1], bottom[0]]; // TL, TR, BR, BL
}

List<DetectedRectangle> _decodeRectanglesFromPayload(
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
        .where((r) => r.corners.length == 4)
        .toList(growable: false);
  } catch (_) {
    return const <DetectedRectangle>[];
  }
}

class _DetectionSnapshot {
  const _DetectionSnapshot({required this.rectangles});
  final List<DetectedRectangle> rectangles;
}
