import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'package:smartscan/features/export/domain/export_models.dart';

class TxtExportService {
  Future<File> export(ExportRequest request) async {
    AppLogger.info('export', 'Preparing TXT export for ${request.documentId}');
    final root = await getTemporaryDirectory();
    final sanitizedTitle =
        request.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
    final outputPath = request.outputPath ??
        p.join(root.path, '${sanitizedTitle}_${request.documentId}.txt');

    final buffer = StringBuffer();
    for (var i = 0; i < request.pages.length; i++) {
      final page = request.pages[i];
      buffer.writeln('Page ${i + 1}');
      buffer.writeln(
          page.ocrText.trim().isEmpty ? '[No text]' : page.ocrText.trim());
      buffer.writeln();
    }

    final file = File(outputPath);
    await file.writeAsString(buffer.toString(), flush: true);
    return file;
  }
}
