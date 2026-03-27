import 'dart:async';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';

final scanControllerProvider =
    StateNotifierProvider.autoDispose<ScanController, ScanViewState>((ref) {
  return ScanController(ref.watch(scanPipelineProvider));
});

class ScanController extends StateNotifier<ScanViewState> {
  ScanController(this._pipeline) : super(const ScanViewState());

  final ScanPipeline _pipeline;
  bool _isAnalyzing = false;
  int _lastAnalyzedAtMs = 0;
  int _lastAutoCaptureAtMs = -_autoCaptureCooldownMs;
  int? _lockedCandidateSinceMs;
  final List<List<DetectedRectangle>> _rectangleHistory =
      <List<DetectedRectangle>>[];
  List<DetectedRectangle> _lastPublishedRectangles =
      const <DetectedRectangle>[];

  static const _analysisThrottleMs = 80;
  static const _autoCaptureCooldownMs = 1500;
  static const _smoothingWindowSize = 5;
  static const _noiseMovementThreshold = 0.006;
  static const _stableMovementThreshold = 0.014;
  static const _uiLockDelayMs = 300;

  void setAutoMode(bool enabled) {
    state = state.copyWith(autoMode: enabled, autoCaptureTriggered: false);
  }

  void setTorchEnabled(bool enabled) {
    state = state.copyWith(torchEnabled: enabled);
  }

  void resetAutoCaptureFlag() {
    if (state.autoCaptureTriggered) {
      state = state.copyWith(autoCaptureTriggered: false);
    }
  }

  Future<void> onPreviewFrame({
    required CameraImage image,
    required int rotationDegrees,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (_isAnalyzing || nowMs - _lastAnalyzedAtMs < _analysisThrottleMs) {
      return;
    }

    final lumaPlane = image.planes.first;
    await onPreviewLumaFrame(
      lumaBytes: Uint8List.fromList(lumaPlane.bytes),
      width: image.width,
      height: image.height,
      bytesPerRow: lumaPlane.bytesPerRow,
      rotationDegrees: rotationDegrees,
      timestampMs: nowMs,
    );
  }

  Future<void> onPreviewLumaFrame({
    required Uint8List lumaBytes,
    required int width,
    required int height,
    required int bytesPerRow,
    required int rotationDegrees,
    int? timestampMs,
  }) async {
    final nowMs = timestampMs ?? DateTime.now().millisecondsSinceEpoch;
    if (_isAnalyzing || nowMs - _lastAnalyzedAtMs < _analysisThrottleMs) {
      return;
    }

    _isAnalyzing = true;
    _lastAnalyzedAtMs = nowMs;

    try {
      final result = await _pipeline.analyzePreviewFrame(
        PreviewFrameInput(
          lumaBytes: lumaBytes,
          width: width,
          height: height,
          bytesPerRow: bytesPerRow,
          rotationDegrees: rotationDegrees,
          timestampMs: nowMs,
        ),
      );

      final triggerAutoCapture = state.autoMode &&
          result.shouldAutoCapture &&
          !state.autoCaptureTriggered &&
          (nowMs - _lastAutoCaptureAtMs >= _autoCaptureCooldownMs);

      if (triggerAutoCapture) {
        _lastAutoCaptureAtMs = nowMs;
      }

      final smoothedRectangles = _smoothRectangles(result.detectedRectangles);
      final movement = _maxCornerMovement(
        _lastPublishedRectangles,
        smoothedRectangles,
      );

      final shouldIgnoreAsNoise = _lastPublishedRectangles.isNotEmpty &&
          movement <= _noiseMovementThreshold;

      final rectanglesForUi =
          shouldIgnoreAsNoise ? _lastPublishedRectangles : smoothedRectangles;

      if (!shouldIgnoreAsNoise) {
        _lastPublishedRectangles = rectanglesForUi;
      }

      final hasRectangles = rectanglesForUi.isNotEmpty;
      final isGeometryStable =
          hasRectangles && movement <= _stableMovementThreshold;
      final lockCandidate =
          result.status == DetectionStatus.locked && isGeometryStable;

      if (lockCandidate) {
        _lockedCandidateSinceMs ??= nowMs;
      } else {
        _lockedCandidateSinceMs = null;
      }

      final isLockedForUi = lockCandidate &&
          _lockedCandidateSinceMs != null &&
          nowMs - _lockedCandidateSinceMs! >= _uiLockDelayMs;

      final statusForUi = !hasRectangles
          ? DetectionStatus.notDetected
          : isLockedForUi
              ? DetectionStatus.locked
              : DetectionStatus.adjusting;

      final stabilityForUi = hasRectangles
          ? ((result.stability * 0.7) +
                  ((1.0 - movement.clamp(0.0, 1.0)) * 0.3))
              .clamp(0.0, 1.0)
          : 0.0;

      state = state.copyWith(
        rectangles: rectanglesForUi,
        detectionStatus: statusForUi,
        confidence: result.confidence,
        stability: stabilityForUi,
        autoCaptureTriggered: triggerAutoCapture,
      );
    } finally {
      _isAnalyzing = false;
    }
  }

  Future<ScanPipelineOutput> processCapture({
    required String documentId,
    required Uint8List jpegBytes,
  }) {
    return _pipeline.process(
      ScanPipelineInput(
        jpegBytes: jpegBytes,
        documentId: documentId,
        detectedRectangles: state.rectangles,
      ),
    );
  }

  List<DetectedRectangle> _smoothRectangles(
      List<DetectedRectangle> rectangles) {
    if (rectangles.isEmpty) {
      _rectangleHistory.clear();
      _lastPublishedRectangles = const <DetectedRectangle>[];
      return const <DetectedRectangle>[];
    }

    final normalized = rectangles
        .where((rectangle) => rectangle.corners.length == 4)
        .map(_cloneRectangle)
        .toList(growable: false);

    if (normalized.isEmpty) {
      _rectangleHistory.clear();
      _lastPublishedRectangles = const <DetectedRectangle>[];
      return const <DetectedRectangle>[];
    }

    if (_rectangleHistory.isNotEmpty &&
        _rectangleHistory.first.length != normalized.length) {
      _rectangleHistory.clear();
    }

    _rectangleHistory.add(normalized);
    if (_rectangleHistory.length > _smoothingWindowSize) {
      _rectangleHistory.removeAt(0);
    }

    return List<DetectedRectangle>.generate(normalized.length, (index) {
      var sumConfidence = 0.0;
      var sumAreaRatio = 0.0;
      final cornerSumsX = List<double>.filled(4, 0.0);
      final cornerSumsY = List<double>.filled(4, 0.0);

      for (final frame in _rectangleHistory) {
        final rectangle = frame[index];
        sumConfidence += rectangle.confidence;
        sumAreaRatio += rectangle.areaRatio;
        for (var cornerIndex = 0; cornerIndex < 4; cornerIndex++) {
          cornerSumsX[cornerIndex] += rectangle.corners[cornerIndex].x;
          cornerSumsY[cornerIndex] += rectangle.corners[cornerIndex].y;
        }
      }

      final count = _rectangleHistory.length;
      final averagedCorners = List<NormalizedCorner>.generate(
        4,
        (cornerIndex) => NormalizedCorner(
          (cornerSumsX[cornerIndex] / count).clamp(0.0, 1.0),
          (cornerSumsY[cornerIndex] / count).clamp(0.0, 1.0),
        ),
      );

      final latest = normalized[index];
      return DetectedRectangle(
        corners: averagedCorners,
        confidence: (sumConfidence / count).clamp(0.0, 1.0),
        areaRatio: (sumAreaRatio / count).clamp(0.0, 1.0),
        label: latest.label,
      );
    });
  }

  double _maxCornerMovement(
    List<DetectedRectangle> previous,
    List<DetectedRectangle> current,
  ) {
    if (previous.isEmpty || current.isEmpty) {
      return 1.0;
    }

    if (previous.length != current.length) {
      return 1.0;
    }

    var maxMovement = 0.0;
    for (var rectIndex = 0; rectIndex < current.length; rectIndex++) {
      final prevRect = previous[rectIndex];
      final currRect = current[rectIndex];
      if (prevRect.corners.length != 4 || currRect.corners.length != 4) {
        return 1.0;
      }

      for (var cornerIndex = 0; cornerIndex < 4; cornerIndex++) {
        final dx =
            currRect.corners[cornerIndex].x - prevRect.corners[cornerIndex].x;
        final dy =
            currRect.corners[cornerIndex].y - prevRect.corners[cornerIndex].y;
        final movement = math.sqrt(dx * dx + dy * dy);
        if (movement > maxMovement) {
          maxMovement = movement;
        }
      }
    }

    return maxMovement;
  }

  DetectedRectangle _cloneRectangle(DetectedRectangle rectangle) {
    return DetectedRectangle(
      corners: rectangle.corners
          .map((corner) => NormalizedCorner(corner.x, corner.y))
          .toList(growable: false),
      confidence: rectangle.confidence,
      areaRatio: rectangle.areaRatio,
      label: rectangle.label,
    );
  }
}

class ScanViewState {
  const ScanViewState({
    this.rectangles = const <DetectedRectangle>[],
    this.detectionStatus = DetectionStatus.notDetected,
    this.confidence = 0,
    this.stability = 0,
    this.autoMode = true,
    this.torchEnabled = false,
    this.autoCaptureTriggered = false,
  });

  final List<DetectedRectangle> rectangles;
  final DetectionStatus detectionStatus;
  final double confidence;
  final double stability;
  final bool autoMode;
  final bool torchEnabled;
  final bool autoCaptureTriggered;

  ScanViewState copyWith({
    List<DetectedRectangle>? rectangles,
    DetectionStatus? detectionStatus,
    double? confidence,
    double? stability,
    bool? autoMode,
    bool? torchEnabled,
    bool? autoCaptureTriggered,
  }) {
    return ScanViewState(
      rectangles: rectangles ?? this.rectangles,
      detectionStatus: detectionStatus ?? this.detectionStatus,
      confidence: confidence ?? this.confidence,
      stability: stability ?? this.stability,
      autoMode: autoMode ?? this.autoMode,
      torchEnabled: torchEnabled ?? this.torchEnabled,
      autoCaptureTriggered: autoCaptureTriggered ?? this.autoCaptureTriggered,
    );
  }
}
