import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smartscan/core/widgets/text_value_dialog.dart';

enum ExportDelivery { share, local }

Future<ExportDelivery?> promptForExportDelivery(
  BuildContext context, {
  String title = 'After export',
}) {
  return showModalBottomSheet<ExportDelivery>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.share_rounded),
            title: const Text('Share to another app'),
            subtitle: const Text('Open the Android share sheet'),
            onTap: () => Navigator.of(context).pop(ExportDelivery.share),
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Save locally'),
            subtitle: const Text('Keep a copy on this device'),
            onTap: () => Navigator.of(context).pop(ExportDelivery.local),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

Future<String?> promptForExportPath(
  BuildContext context, {
  required String extension,
  required String currentTitle,
  required ExportDelivery delivery,
}) async {
  final name = await showTextValueDialog(
    context,
    title: 'Save as .$extension',
    confirmLabel: 'Save',
    initialValue: currentTitle,
    hintText: 'File name',
  );

  final trimmed = name?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }

  final sanitized = sanitizeFileName(trimmed);
  final baseDir = delivery == ExportDelivery.share
      ? await getTemporaryDirectory()
      : await resolveLocalExportDirectory();
  return p.join(baseDir.path, '$sanitized.$extension');
}

Future<Directory> resolveLocalExportDirectory() async {
  try {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final exportDir = Directory(p.join(downloadsDir.path, 'SmartScan'));
      await exportDir.create(recursive: true);
      return exportDir;
    }
  } catch (_) {}

  final docsDir = await getApplicationDocumentsDirectory();
  final exportDir = Directory(p.join(docsDir.path, 'exports'));
  await exportDir.create(recursive: true);
  return exportDir;
}

Future<void> handleExportedFile(
  BuildContext context,
  File file,
  String title,
  ExportDelivery delivery,
) async {
  if (!context.mounted) return;
  if (delivery == ExportDelivery.share) {
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Exported Document: $title',
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Saved locally: ${file.path}')),
  );
}

String sanitizeFileName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return 'document';
  }
  return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
}
