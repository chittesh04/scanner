import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';

class DocxExportService {
  Future<File> export(ExportRequest request) async {
    final archive = Archive()
      ..addFile(ArchiveFile('word/document.xml', request.title.length, request.title.codeUnits));

    final encoded = ZipEncoder().encode(archive)!;
    final root = await getApplicationDocumentsDirectory();
    final file = File(p.join(root.path, '${request.title}_${request.documentId}.docx'));
    await file.writeAsBytes(encoded, flush: true);
    return file;
  }
}
