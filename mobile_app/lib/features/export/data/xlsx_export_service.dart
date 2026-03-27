import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/features/export/domain/export_models.dart';

class XlsxExportService {
  Future<File> export(ExportRequest request) async {
    final csv = request.ocrTexts.asMap().entries.map((e) => '${e.key + 1},"${e.value.replaceAll('"', '""')}"').join('\n');
    final archive = Archive()..addFile(ArchiveFile('xl/worksheets/sheet1.xml', csv.length, csv.codeUnits));
    final encoded = ZipEncoder().encode(archive)!;

    final root = await getApplicationDocumentsDirectory();
    final file = File(p.join(root.path, '${request.title}_${request.documentId}.xlsx'));
    await file.writeAsBytes(encoded, flush: true);
    return file;
  }
}
