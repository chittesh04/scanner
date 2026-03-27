import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan/core/security/encryption_service.dart';
import 'package:smartscan/core/storage/file_storage_service.dart';
import 'package:smartscan_database/isar_schema.dart';
import 'package:workmanager/workmanager.dart';

/// Top-level callback for WorkManager.
///
/// Runs in an isolated background process with its own Flutter engine.
/// Re-initialises Isar, encryption utilities, and ML Kit before processing
/// every page whose [OcrStatus] is still [OcrStatus.pending].
@pragma('vm:entry-point')
void ocrBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    try {
      switch (task) {
        case 'ocr-index-task':
          return _handleOcrIndexTask(inputData);
        case 'cloud-sync-task':
          // Cloud sync handled elsewhere; acknowledge as successful.
          return true;
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  });
}

Future<bool> _handleOcrIndexTask(Map<String, dynamic>? inputData) async {
  final documentId = inputData?['documentId'] as String?;
  if (documentId == null) return false;

  // --- Open a fresh Isar instance for this isolate ---
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      DocumentEntitySchema,
      CollectionEntitySchema,
      PageEntitySchema,
      OcrBlockEntitySchema,
      TagEntitySchema,
    ],
    directory: dir.path,
    name: 'smartscan',
  );

  final encryptionService = EncryptionService();
  final fileStorage = FileStorageService(encryptionService);
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  try {
    final pages = await isar.pageEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .ocrStatusEqualTo(OcrStatus.pending)
        .findAll();

    for (final page in pages) {
      // Mark as processing
      await isar.writeTxn(() async {
        page.ocrStatus = OcrStatus.processing;
        await isar.pageEntitys.put(page);
      });

      try {
        // Decrypt the processed image into a temp file for ML Kit
        final encryptedFile = File(page.processedImagePath);
        final imageBytes = await fileStorage.readEncrypted(encryptedFile);
        final tempFile = File('${encryptedFile.path}.mlkit_tmp');
        await tempFile.writeAsBytes(imageBytes);

        // Run ML Kit text recognition
        final inputImage = InputImage.fromFile(tempFile);
        final recognized = await textRecognizer.processImage(inputImage);

        // Clean up temp file immediately
        await tempFile.delete();

        // Persist OCR results inside a single transaction
        await isar.writeTxn(() async {
          // Clear any stale blocks
          await page.ocrBlocks.load();
          if (page.ocrBlocks.isNotEmpty) {
            await isar.ocrBlockEntitys
                .deleteAll(page.ocrBlocks.map((b) => b.id).toList());
            page.ocrBlocks.clear();
          }

          final langCode =
              recognized.blocks.expand((b) => b.recognizedLanguages).firstOrNull ?? 'en';

          for (final block in recognized.blocks) {
            for (final line in block.lines) {
              for (final element in line.elements) {
                final ocrBlock = OcrBlockEntity()
                  ..pageId = page.pageId
                  ..text = element.text
                  ..left = element.boundingBox.left
                  ..top = element.boundingBox.top
                  ..right = element.boundingBox.right
                  ..bottom = element.boundingBox.bottom
                  ..languageCode = langCode;

                await isar.ocrBlockEntitys.put(ocrBlock);
                page.ocrBlocks.add(ocrBlock);
              }
            }
          }

          await page.ocrBlocks.save();

          page.fullText = recognized.text;
          page.ocrStatus = OcrStatus.completed;
          page.updatedAt = DateTime.now();
          await isar.pageEntitys.put(page);
        });
      } catch (_) {
        // Mark as failed so it can be retried later
        await isar.writeTxn(() async {
          page.ocrStatus = OcrStatus.failed;
          await isar.pageEntitys.put(page);
        });
      }
    }

    return true;
  } finally {
    await textRecognizer.close();
    await isar.close();
  }
}
