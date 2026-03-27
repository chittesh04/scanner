import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';
import 'package:smartscan/core/storage/file_storage_service.dart';

import 'package:smartscan/features/signature/domain/signature_repository.dart';

class PdfExportService {
  PdfExportService(this._storageService, this._signatureRepository);

  final FileStorageService _storageService;
  final SignatureRepository _signatureRepository;

  Future<File> export(ExportRequest request) async {
    final pdf = pw.Document();
    final signatureBytes = await _signatureRepository.loadSignature();
    final signatureImage = signatureBytes != null ? pw.MemoryImage(signatureBytes) : null;

    for (var i = 0; i < request.pageImagePaths.length; i++) {
      final imageFile = File(request.pageImagePaths[i]);
      if (!await imageFile.exists()) continue;

      final Uint8List imageBytes = await _storageService.readEncrypted(imageFile);
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Stack(
              alignment: pw.Alignment.center,
              children: [
                pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain)),
                
                if (i < request.signatures.length && request.signatures[i] != null && signatureImage != null)
                  pw.Align(
                    alignment: pw.Alignment(
                      (request.signatures[i]!.x * 2) - 1, 
                      (request.signatures[i]!.y * 2) - 1,
                    ),
                    child: pw.Transform.scale(
                      scale: request.signatures[i]!.scale,
                      child: pw.SizedBox(
                        width: 200,
                        child: pw.Image(signatureImage),
                      ),
                    ),
                  ),

                if (i < request.ocrTexts.length)
                  pw.Positioned.fill(
                    child: pw.Opacity(
                      opacity: 0.0,
                      child: pw.Text(request.ocrTexts[i]),
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
}
