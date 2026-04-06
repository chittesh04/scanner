import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'package:smartscan_models/document.dart';

class ZipExportService {
  Future<File> exportDocuments(List<Document> documents) async {
    if (documents.isEmpty) {
      throw ArgumentError('No documents selected for ZIP export.');
    }

    AppLogger.info(
        'export', 'Preparing ZIP export for ${documents.length} documents');
    final archive = Archive();

    for (final document in documents) {
      final safeTitle = _sanitize(document.title);
      final textContent = _buildDocumentText(document);
      final bytes = utf8.encode(textContent);
      archive.addFile(ArchiveFile(
          '$safeTitle-${document.documentId}.txt', bytes.length, bytes));
    }

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw StateError('Failed to encode ZIP archive.');
    }

    final root = await getTemporaryDirectory();
    final filename =
        'smartscan_export_${DateTime.now().millisecondsSinceEpoch}.zip';
    final output = File(p.join(root.path, filename));
    await output.writeAsBytes(encoded, flush: true);
    return output;
  }

  String _buildDocumentText(Document document) {
    final buffer = StringBuffer();
    buffer.writeln(document.title);
    buffer.writeln('Document ID: ${document.documentId}');
    buffer.writeln('Updated: ${document.updatedAt.toIso8601String()}');
    buffer.writeln();

    for (final page in document.pages) {
      final text = page.ocrText?.trim();
      buffer.writeln('Page ${page.order + 1}');
      buffer.writeln(text == null || text.isEmpty ? '[No text]' : text);
      buffer.writeln();
    }
    return buffer.toString();
  }

  String _sanitize(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'document';
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
