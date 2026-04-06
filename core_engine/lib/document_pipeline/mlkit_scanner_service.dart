import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

import 'package:smartscan_core_engine/document_pipeline/scan_pipeline.dart';
import 'package:smartscan_core_engine/logging/engine_logger.dart';
import 'package:smartscan_core_engine/ports/secure_storage_port.dart';

/// Document scanning service using Google ML Kit Document Scanner.
class MlKitScannerService implements ScanPipeline {
  MlKitScannerService(this._storagePort);

  final SecureStoragePort _storagePort;
  final _uuid = const Uuid();

  /// Launches the native ML Kit Document Scanner and returns scanned pages.
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
      EngineLogger.info('scan', 'Starting ML Kit scan for $documentId');
      final result = await documentScanner.scanDocument();

      if (result.images.isEmpty) {
        EngineLogger.info('scan', 'No pages returned for $documentId');
        return null;
      }

      final pages = <ScannedPage>[];

      for (final imagePath in result.images) {
        try {
          final imageFile = File(imagePath);
          if (!await imageFile.exists()) {
            EngineLogger.error(
              'scan',
              'Scanner output file not found: $imagePath',
            );
            continue;
          }

          final imageBytes = await imageFile.readAsBytes();
          final decoded = img.decodeImage(imageBytes);
          if (decoded == null) {
            EngineLogger.error(
              'scan',
              'Failed to decode scanner output image: $imagePath',
            );
            continue;
          }

          final pageId = _uuid.v4();

          final thumbWidth = 240;
          final thumbHeight =
              (thumbWidth * decoded.height / decoded.width).round();
          final thumbnail =
              img.copyResize(decoded, width: thumbWidth, height: thumbHeight);
          final thumbnailBytes =
              Uint8List.fromList(img.encodeJpg(thumbnail, quality: 72));

          final rawPath = await _storagePort.writeImageBytes(
            documentId,
            pageId,
            imageBytes,
            processed: false,
          );

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
        } catch (error, stackTrace) {
          EngineLogger.error(
            'scan',
            'Failed while processing scanned page: $imagePath',
            error: error,
            stackTrace: stackTrace,
          );
        }
      }

      if (pages.isEmpty) {
        EngineLogger.error(
          'scan',
          'All scanned pages failed to process for $documentId',
        );
        return null;
      }

      EngineLogger.info(
        'scan',
        'Scan completed for $documentId with ${pages.length} page(s)',
      );
      return ScanPipelineOutput(pages: pages);
    } catch (error, stackTrace) {
      EngineLogger.error(
        'scan',
        'Scanner invocation failed for $documentId',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    } finally {
      documentScanner.close();
    }
  }

  /// No-op: ML Kit handles preview analysis natively.
  @override
  Future<FrameAnalysisResult> analyzePreviewFrame(
    PreviewFrameInput input,
  ) async {
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
