import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:smartscan/features/scan/presentation/scan_controller.dart';
import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';

void main() {
  group('ScanController', () {
    test('updates detection state from preview analysis', () async {
      final pipeline = _FakeScanPipeline(
        analysisResult: const FrameAnalysisResult(
          detectedRectangles: [
            DetectedRectangle(
              corners: [
                NormalizedCorner(0.1, 0.1),
                NormalizedCorner(0.8, 0.1),
                NormalizedCorner(0.8, 0.9),
                NormalizedCorner(0.1, 0.9),
              ],
              confidence: 0.88,
              areaRatio: 0.4,
              label: 'Page 1',
            )
          ],
          status: DetectionStatus.locked,
          confidence: 0.88,
          stability: 0.97,
          shouldAutoCapture: true,
        ),
      );
      final controller = ScanController(pipeline);

      await controller.onPreviewLumaFrame(
        lumaBytes: Uint8List.fromList(List<int>.filled(100, 127)),
        width: 10,
        height: 10,
        bytesPerRow: 10,
        rotationDegrees: 0,
        timestampMs: 1000,
      );
      expect(controller.state.autoCaptureTriggered, isTrue);

      await controller.onPreviewLumaFrame(
        lumaBytes: Uint8List.fromList(List<int>.filled(100, 127)),
        width: 10,
        height: 10,
        bytesPerRow: 10,
        rotationDegrees: 0,
        timestampMs: 1400,
      );

      await controller.onPreviewLumaFrame(
        lumaBytes: Uint8List.fromList(List<int>.filled(100, 127)),
        width: 10,
        height: 10,
        bytesPerRow: 10,
        rotationDegrees: 0,
        timestampMs: 1701,
      );

      expect(controller.state.rectangles.length, 1);
      expect(controller.state.detectionStatus, DetectionStatus.locked);
      expect(controller.state.confidence, closeTo(0.88, 0.0001));
      expect(controller.state.stability, closeTo(0.979, 0.0001));
      expect(controller.state.autoCaptureTriggered, isFalse);
    });

    test('forwards capture request to pipeline with current document id',
        () async {
      final pipeline = _FakeScanPipeline();
      final controller = ScanController(pipeline);
      final bytes = Uint8List.fromList(<int>[1, 2, 3]);

      final output = await controller.processCapture(
        documentId: 'doc-123',
        jpegBytes: bytes,
      );

      expect(pipeline.lastInput, isNotNull);
      expect(pipeline.lastInput!.documentId, 'doc-123');
      expect(pipeline.lastInput!.jpegBytes, bytes);
      expect(output.pages.length, 1);
      expect(output.pages.first.label, 'Page 1');
    });

    test('auto mode toggle resets trigger flag', () {
      final pipeline = _FakeScanPipeline(
        analysisResult: const FrameAnalysisResult(
          detectedRectangles: [],
          status: DetectionStatus.notDetected,
          confidence: 0,
          stability: 0,
          shouldAutoCapture: true,
        ),
      );
      final controller = ScanController(pipeline);

      controller.setAutoMode(false);

      expect(controller.state.autoMode, isFalse);
      expect(controller.state.autoCaptureTriggered, isFalse);
    });

    test('enforces cooldown between auto-capture triggers', () async {
      final pipeline = _FakeScanPipeline(
        analysisResult: const FrameAnalysisResult(
          detectedRectangles: [
            DetectedRectangle(
              corners: [
                NormalizedCorner(0.2, 0.2),
                NormalizedCorner(0.8, 0.2),
                NormalizedCorner(0.8, 0.8),
                NormalizedCorner(0.2, 0.8),
              ],
              confidence: 0.9,
              areaRatio: 0.4,
              label: 'Page 1',
            )
          ],
          status: DetectionStatus.locked,
          confidence: 0.9,
          stability: 0.98,
          shouldAutoCapture: true,
        ),
      );
      final controller = ScanController(pipeline);

      await controller.onPreviewLumaFrame(
        lumaBytes: Uint8List.fromList(List<int>.filled(100, 125)),
        width: 10,
        height: 10,
        bytesPerRow: 10,
        rotationDegrees: 0,
        timestampMs: 1000,
      );
      expect(controller.state.autoCaptureTriggered, isTrue);

      controller.resetAutoCaptureFlag();
      expect(controller.state.autoCaptureTriggered, isFalse);

      await controller.onPreviewLumaFrame(
        lumaBytes: Uint8List.fromList(List<int>.filled(100, 126)),
        width: 10,
        height: 10,
        bytesPerRow: 10,
        rotationDegrees: 0,
        timestampMs: 2600,
      );
      expect(controller.state.autoCaptureTriggered, isTrue);

      controller.resetAutoCaptureFlag();

      await controller.onPreviewLumaFrame(
        lumaBytes: Uint8List.fromList(List<int>.filled(100, 127)),
        width: 10,
        height: 10,
        bytesPerRow: 10,
        rotationDegrees: 0,
        timestampMs: 3000,
      );
      expect(controller.state.autoCaptureTriggered, isFalse);
    });
  });
}

class _FakeScanPipeline implements ScanPipeline {
  _FakeScanPipeline({FrameAnalysisResult? analysisResult})
      : _analysisResult = analysisResult ??
            const FrameAnalysisResult(
              detectedRectangles: [],
              status: DetectionStatus.notDetected,
              confidence: 0,
              stability: 0,
              shouldAutoCapture: false,
            );

  final FrameAnalysisResult _analysisResult;
  ScanPipelineInput? lastInput;

  @override
  Future<FrameAnalysisResult> analyzePreviewFrame(
      PreviewFrameInput input) async {
    return _analysisResult;
  }

  @override
  Future<ScanPipelineOutput> process(ScanPipelineInput input) async {
    lastInput = input;
    return const ScanPipelineOutput(
      pages: [
        ScannedPage(
          rawImagePath: '/tmp/raw.jpg',
          processedImagePath: '/tmp/proc.jpg',
          width: 100,
          height: 200,
          label: 'Page 1',
        )
      ],
    );
  }
}
