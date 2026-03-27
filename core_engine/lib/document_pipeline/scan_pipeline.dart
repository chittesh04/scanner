import 'dart:typed_data';

enum DetectionStatus { notDetected, adjusting, locked }

class NormalizedCorner {
  const NormalizedCorner(this.x, this.y);

  final double x;
  final double y;
}

class DetectedRectangle {
  const DetectedRectangle({
    required this.corners,
    required this.confidence,
    required this.areaRatio,
    required this.label,
  });

  final List<NormalizedCorner> corners;
  final double confidence;
  final double areaRatio;
  final String label;
}

class PreviewFrameInput {
  const PreviewFrameInput({
    required this.lumaBytes,
    required this.width,
    required this.height,
    required this.bytesPerRow,
    required this.rotationDegrees,
    required this.timestampMs,
  });

  final Uint8List lumaBytes;
  final int width;
  final int height;
  final int bytesPerRow;
  final int rotationDegrees;
  final int timestampMs;
}

class FrameAnalysisResult {
  const FrameAnalysisResult({
    required this.detectedRectangles,
    required this.status,
    required this.confidence,
    required this.stability,
    required this.shouldAutoCapture,
  });

  final List<DetectedRectangle> detectedRectangles;
  final DetectionStatus status;
  final double confidence;
  final double stability;
  final bool shouldAutoCapture;
}

class ScanPipelineInput {
  const ScanPipelineInput({
    required this.jpegBytes,
    required this.documentId,
    this.detectedRectangles = const [],
  });

  final Uint8List jpegBytes;
  final String documentId;
  final List<DetectedRectangle> detectedRectangles;
}

class ScannedPage {
  const ScannedPage({
    required this.rawImagePath,
    required this.processedImagePath,
    required this.width,
    required this.height,
    required this.label,
    this.thumbnailJpegBytes,
  });

  final String rawImagePath;
  final String processedImagePath;
  final int width;
  final int height;
  final String label;
  final Uint8List? thumbnailJpegBytes;
}

class ScanPipelineOutput {
  const ScanPipelineOutput({required this.pages});

  final List<ScannedPage> pages;

  // Backward-compatible single-page accessors.
  String get rawImagePath => pages.first.rawImagePath;
  String get processedImagePath => pages.first.processedImagePath;
  int get width => pages.first.width;
  int get height => pages.first.height;
  bool get isMultiPage => pages.length > 1;
}

abstract interface class ScanPipeline {
  Future<FrameAnalysisResult> analyzePreviewFrame(PreviewFrameInput input);
  Future<ScanPipelineOutput> process(ScanPipelineInput input);
}
