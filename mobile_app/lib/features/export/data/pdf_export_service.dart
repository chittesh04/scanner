import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';
import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan/features/signature/domain/signature_repository.dart';

class _PdfExportPayload {
  _PdfExportPayload({
    required this.outputPath,
    required this.signatureBytes,
    required this.pages,
    required this.imageBytesList,
  });

  final String outputPath;
  Uint8List? signatureBytes;
  final List<PageExportData> pages;
  final List<Uint8List?> imageBytesList;
}

class PdfExportService {
  PdfExportService(this._storageService, this._signatureRepository);

  final FileStorageServiceImpl _storageService;
  final SignatureRepository _signatureRepository;

  Future<File> export(ExportRequest request) async {
    final signatureBytes = await _signatureRepository.loadSignature();

    String path = request.outputPath ?? '';
    if (path.isEmpty) {
      final root = await getTemporaryDirectory();
      path = p.join(root.path, '${request.title}_${request.documentId}.pdf');
    }

    final imageBytesList = <Uint8List?>[];
    for (final page in request.pages) {
      final imageFile = File(page.imagePath);
      if (!await imageFile.exists()) {
        imageBytesList.add(null);
        continue;
      }
      imageBytesList.add(await _storageService.readEncrypted(imageFile));
    }

    final payload = _PdfExportPayload(
      outputPath: path,
      signatureBytes: signatureBytes,
      pages: request.pages,
      imageBytesList: imageBytesList,
    );

    final resultPath = await Isolate.run(() => _buildPdfIsolate(payload));
    return File(resultPath);
  }

  static Future<String> _buildPdfIsolate(_PdfExportPayload payload) async {
    final pdf = pw.Document();
    pw.MemoryImage? signatureImage;
    if (payload.signatureBytes != null) {
      signatureImage = pw.MemoryImage(payload.signatureBytes!);
      payload.signatureBytes = null; // Aggressive nullification hinting
    }

    for (var i = 0; i < payload.pages.length; i++) {
      final page = payload.pages[i];
      var imageBytes = payload.imageBytesList[i];
      payload.imageBytesList[i] = null; // Free from list immediately

      if (imageBytes == null) continue;

      // Downscaling optimization
      final decodedImage = img.decodeImage(imageBytes);
      imageBytes = null; // Free raw bytes

      if (decodedImage != null) {
        final longestSide = math.max(decodedImage.width, decodedImage.height);
        if (longestSide > 1500) {
          final targetWidth = decodedImage.width > decodedImage.height 
              ? 1240 
              : (1240 * (decodedImage.width / decodedImage.height)).round();
          final resized = img.copyResize(decodedImage, width: targetWidth);
          imageBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 85));
        } else {
          imageBytes = Uint8List.fromList(img.encodeJpg(decodedImage, quality: 90));
        }
      }

      if (imageBytes == null) continue;
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final pageWidth = context.page.pageFormat.availableWidth;
            final pageHeight = context.page.pageFormat.availableHeight;

            final scaleX = pageWidth / page.imageWidth;
            final scaleY = pageHeight / page.imageHeight;

            return pw.Stack(
              children: [
                pw.Positioned.fill(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
                for (final block in page.ocrBlocks)
                  _buildInvisibleTextBlock(block, scaleX, scaleY, pageHeight),
                if (page.signature != null && signatureImage != null)
                  _buildPdfSignature(page.signature!, signatureImage, pageWidth, pageHeight),
              ],
            );
          },
        ),
      );
    }

    final file = File(payload.outputPath);
    final pdfBytes = await pdf.save();
    await file.writeAsBytes(pdfBytes, flush: true);
    return payload.outputPath;
  }

  static pw.Widget _buildPdfSignature(
    PageSignature signature,
    pw.MemoryImage signatureImage,
    double pageWidth,
    double pageHeight,
  ) {
    final baseSignatureWidth = pageWidth * 0.25; 
    final finalSignatureWidth = baseSignatureWidth * signature.scale;
    final finalSignatureHeight = finalSignatureWidth / 2.0; 

    final pdfLeft = signature.x * pageWidth;
    final pdfTop = signature.y * pageHeight;
    final pdfBottom = pageHeight - pdfTop - finalSignatureHeight;

    return pw.Positioned(
      left: pdfLeft,
      bottom: pdfBottom,
      child: pw.SizedBox(
        width: finalSignatureWidth,
        height: finalSignatureHeight,
        child: pw.Image(signatureImage, fit: pw.BoxFit.contain),
      ),
    );
  }

  /// Creates a positioned, fully transparent text widget whose bounding
  /// box matches the OCR word's location in the image.
  ///
  /// PDF coordinates start at the **bottom-left**; OCR coordinates start
  /// at the **top-left**. We convert by flipping the vertical axis:
  ///   `pdfBottom = pageHeight - (ocrBottom * scaleY)`
  static pw.Widget _buildInvisibleTextBlock(
    ExportOcrBlock block,
    double scaleX,
    double scaleY,
    double pageHeight,
  ) {
    final pdfLeft = block.left * scaleX;
    final pdfBottom = pageHeight - (block.bottom * scaleY);
    final pdfWidth = (block.right - block.left) * scaleX;
    final pdfHeight = (block.bottom - block.top) * scaleY;

    // Font size is the block height in PDF points, clamped to avoid
    // degenerate sizes for tiny or empty blocks.
    final fontSize = pdfHeight.clamp(1.0, 200.0);

    return pw.Positioned(
      left: pdfLeft,
      bottom: pdfBottom,
      child: pw.SizedBox(
        width: pdfWidth,
        height: pdfHeight,
        child: pw.Opacity(
          opacity: 0.0,
          child: pw.Text(
            block.text,
            style: pw.TextStyle(fontSize: fontSize),
            maxLines: 1,
            overflow: pw.TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}
