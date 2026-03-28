import 'dart:ui';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:cryptography/cryptography.dart';
import 'package:smartscan_database/database_manager.dart';
import 'package:smartscan_database/isar_schema.dart';
import 'package:smartscan_services/security/encryption_service.dart';
import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan_core_engine/core_engine.dart';
import 'package:workmanager/workmanager.dart';
import 'package:isar/isar.dart';

@pragma('vm:entry-point')
void ocrBackgroundCallback() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    
    try {
      switch (task) {
        case 'ocr-index-task':
          return _handleOcrIndexTask(inputData);
        case 'cloud-sync-task':
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

  final isar = await DatabaseManager.openInstance();

  final encryptionService = EncryptionService();
  final fileStorage = FileStorageServiceImpl(encryptionService);
  final ocrPipeline = OcrServiceImpl(fileStorage);

  try {
    final pages = await isar.pageEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .ocrStatusEqualTo(OcrStatus.pending)
        .findAll();

    for (final page in pages) {
      await isar.writeTxn(() async {
        page.ocrStatus = OcrStatus.processing;
        await isar.pageEntitys.put(page);
      });

      try {
        final result = await ocrPipeline.recognizeText(page.processedImagePath);

        await isar.writeTxn(() async {
          await page.ocrBlocks.load();
          if (page.ocrBlocks.isNotEmpty) {
            await isar.ocrBlockEntitys
                .deleteAll(page.ocrBlocks.map((b) => b.id).toList());
            page.ocrBlocks.clear();
          }

          final langCode = result.detectedLanguages.firstOrNull ?? 'en';

          for (final word in result.words) {
             final ocrBlock = OcrBlockEntity()
                ..pageId = page.pageId
                ..text = word.text
                ..left = word.left
                ..top = word.top
                ..right = word.right
                ..bottom = word.bottom
                ..languageCode = langCode;

             await isar.ocrBlockEntitys.put(ocrBlock);
             page.ocrBlocks.add(ocrBlock);
          }

          await page.ocrBlocks.save();

        page.ocrStatus = OcrStatus.completed;
          page.updatedAt = DateTime.now();
          await isar.pageEntitys.put(page);
        });
      } on SecretBoxAuthenticationError catch (_) {
        await isar.writeTxn(() async {
          page.ocrStatus = OcrStatus.failed;
          await isar.pageEntitys.put(page);
        });
        return true; // Permanent encryption fault drops the job
      } on PathNotFoundException catch (_) {
        return true; // File dropped locally, drop job
      } catch (_) {
        return false; // Escalate failure to WorkManager back-off logic
      }
    }

    return true;
  } finally {
    await ocrPipeline.dispose();
    await DatabaseManager.instance.close();
  }
}
