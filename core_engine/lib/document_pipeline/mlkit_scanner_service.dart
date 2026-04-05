import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:uuid/uuid.dart';

import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:smartscan_core_engine/ports/secure_storage_port.dart';

/// Document scanning service using Google ML Kit Document Scanner.
///
/// Replaces the previous OpenCV FFI implementation. The native scanner
/// handles camera, edge detection, perspective correction, and cropping
/// automatically — no isolates, no FFI, no memory leaks.
class MlKitScannerService implements ScanPipeline {
  MlKitScannerService(this._storagePort);

  final SecureStoragePort _storagePort;
  final _uuid = const Uuid();

  /// Launches the native ML Kit Document Scanner and returns scanned pages.
  ///
  /// The scanner handles camera, edge detection, perspective warping, and
  /// user review natively. Returns already-cropped JPEG images.
  Future<ScanPipelineOutput?> scanDocument({
    required String documentId,
    int pageLimit = 50,
    bool isGalleryImport = true,
  }) async {
    final documentScanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.full,
        pageLimit: pageLimit,
        isGalleryImport: isGalleryImport,
      ),
    );

    try {
      final result = await documentScanner.scanDocument();

      if (result.images.isEmpty) {
        return null;
      }

      final pages = <ScannedPage>[];

      for (final imagePath in result.images) {
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) continue;

        final imageBytes = await imageFile.readAsBytes();
        final decoded = img.decodeImage(imageBytes);
        if (decoded == null) continue;

        final pageId = _uuid.v4();

        // Generate thumbnail (240px wide)
        final thumbWidth = 240;
        final thumbHeight =
            (thumbWidth * decoded.height / decoded.width).round();
        final thumbnail =
            img.copyResize(decoded, width: thumbWidth, height: thumbHeight);
        final thumbnailBytes =
            Uint8List.fromList(img.encodeJpg(thumbnail, quality: 72));

        // Save raw image (the ML Kit output is already perspective-corrected)
        final rawPath = await _storagePort.writeImageBytes(
          documentId,
          pageId,
          imageBytes,
          processed: false,
        );

        // Save processed image (same as raw since ML Kit already processes it)
        final processedPath = await _storagePort.writeImageBytes(
          documentId,
          pageId,
          imageBytes,
          processed: true,
        );

        pages.add(ScannedPage(
          rawImagePath: rawPath,
          processedImagePath: processedPath,
          width: decoded.width,
          height: decoded.height,
          label: 'Page ${pages.length + 1}',
          thumbnailJpegBytes: thumbnailBytes,
        ));
      }

      if (pages.isEmpty) return null;
      return ScanPipelineOutput(pages: pages);
    } catch (e) {
      rethrow;
    } finally {
      documentScanner.close();
    }
  }

  // ── ScanPipeline interface (kept for backward compatibility) ──────────

  /// No-op: ML Kit handles preview analysis natively.
  @override
  Future<FrameAnalysisResult> analyzePreviewFrame(
      PreviewFrameInput input) async {
    return const FrameAnalysisResult(
      detectedRectangles: [],
      status: DetectionStatus.notDetected,
      confidence: 0,
      stability: 0,
      shouldAutoCapture: false,
    );
  }

  /// No-op: Use [scanDocument] instead.
  @override
  Future<ScanPipelineOutput> process(ScanPipelineInput input) async {
    return const ScanPipelineOutput(pages: []);
  }
}
