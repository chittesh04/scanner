import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';
import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan/features/signature/domain/signature_repository.dart';

class PdfExportService {
  PdfExportService(this._storageService, this._signatureRepository);

  final FileStorageServiceImpl _storageService;
  final SignatureRepository _signatureRepository;

  Future<File> export(ExportRequest request) async {
    final pdf = pw.Document();
    final signatureBytes = await _signatureRepository.loadSignature();
    final signatureImage =
        signatureBytes != null ? pw.MemoryImage(signatureBytes) : null;

    for (final page in request.pages) {
      final imageFile = File(page.imagePath);
      if (!await imageFile.exists()) continue;

      final Uint8List imageBytes =
          await _storageService.readEncrypted(imageFile);
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final pageWidth = context.page.pageFormat.availableWidth;
            final pageHeight = context.page.pageFormat.availableHeight;

            // Scale factor from image pixels → PDF points.
            final scaleX = pageWidth / page.imageWidth;
            final scaleY = pageHeight / page.imageHeight;

            return pw.Stack(
              children: [
                // 1) Full-page scanned image as background.
                pw.Positioned.fill(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),

                // 2) Invisible text overlay — one widget per OCR word,
                //    positioned exactly over the corresponding region in
                //    the image so PDF readers can select/copy/search.
                for (final block in page.ocrBlocks)
                  _buildInvisibleTextBlock(
                    block,
                    scaleX,
                    scaleY,
                    pageHeight,
                  ),

                // 3) Signature overlay (if present).
                if (page.signature != null && signatureImage != null)
                  pw.Align(
                    alignment: pw.Alignment(
                      (page.signature!.x * 2) - 1,
                      (page.signature!.y * 2) - 1,
                    ),
                    child: pw.Transform.scale(
                      scale: page.signature!.scale,
                      child: pw.SizedBox(
                        width: 200,
                        child: pw.Image(signatureImage),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    }

    final String path;
    if (request.outputPath != null) {
      path = request.outputPath!;
    } else {
      final root = await getTemporaryDirectory();
      path = p.join(root.path, '${request.title}_${request.documentId}.pdf');
    }
    final file = File(path);
    await file.writeAsBytes(await pdf.save(), flush: true);
    return file;
  }

  /// Creates a positioned, fully transparent text widget whose bounding
  /// box matches the OCR word's location in the image.
  ///
  /// PDF coordinates start at the **bottom-left**; OCR coordinates start
  /// at the **top-left**. We convert by flipping the vertical axis:
  ///   `pdfBottom = pageHeight - (ocrBottom * scaleY)`
  pw.Widget _buildInvisibleTextBlock(
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
