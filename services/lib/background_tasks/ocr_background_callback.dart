import 'dart:io';
import 'dart:ui';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/widgets.dart';
import 'package:isar/isar.dart';
import 'package:smartscan_core_engine/core_engine.dart';
import 'package:smartscan_database/database_manager.dart';
import 'package:smartscan_database/isar_schema.dart';
import 'package:smartscan_services/background_tasks/retry_policy.dart';
import 'package:smartscan_services/logging/services_logger.dart';
import 'package:smartscan_services/security/file_storage_service.dart';
import 'package:smartscan_services/security/key_manager.dart';
import 'package:workmanager/workmanager.dart';

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
          ServicesLogger.info('background', 'Cloud sync task triggered');
          return true;
        default:
          ServicesLogger.warn('background', 'Unknown task: $task');
          return false;
      }
    } catch (error, stackTrace) {
      ServicesLogger.error(
        'background',
        'Unhandled error in background task $task',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  });
}

Future<bool> _handleOcrIndexTask(Map<String, dynamic>? inputData) async {
  const maxPagesPerRun = 10;
  const retryPolicy = RetryPolicy(maxAttempts: 3);

  final documentId = inputData?['documentId'] as String?;
  if (documentId == null || documentId.trim().isEmpty) {
    ServicesLogger.warn('background', 'OCR task missing documentId');
    return false;
  }

  ServicesLogger.info('background', 'OCR task started for $documentId');

  final isar = await DatabaseManager.openInstance();
  final masterKey = await KeyManager.getOrGenerateMasterKey();
  final fileStorage = FileStorageServiceImpl(masterKey);
  final ocrPipeline = OcrServiceImpl(fileStorage);

  try {
    final allPendingPages = await isar.pageEntitys
        .filter()
        .documentIdEqualTo(documentId)
        .ocrStatusEqualTo(OcrStatus.pending)
        .sortByOrder()
        .findAll();

    if (allPendingPages.isEmpty) {
      ServicesLogger.info('background', 'No pending OCR pages for $documentId');
      return true;
    }
    final pages = allPendingPages.take(maxPagesPerRun).toList(growable: false);
    final hasRemaining = allPendingPages.length > pages.length;

    for (final page in pages) {
      await isar.writeTxn(() async {
        page.ocrStatus = OcrStatus.processing;
        await isar.pageEntitys.put(page);
      });

      try {
        final result = await retryPolicy.run(
          () => ocrPipeline.recognizeText(page.processedImagePath),
        );

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

          page.fullText = result.fullText.trim();
          page.ocrStatus = OcrStatus.completed;
          page.updatedAt = DateTime.now();
          await isar.pageEntitys.put(page);
        });
      } on SecretBoxAuthenticationError catch (error, stackTrace) {
        await isar.writeTxn(() async {
          page.ocrStatus = OcrStatus.failed;
          await isar.pageEntitys.put(page);
        });

        ServicesLogger.error(
          'background',
          'Permanent encryption failure for page ${page.pageId}',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      } on PathNotFoundException catch (error, stackTrace) {
        ServicesLogger.warn(
          'background',
          'Image file missing for page ${page.pageId}; dropping task',
          error: error,
          stackTrace: stackTrace,
        );
        return true;
      } catch (error, stackTrace) {
        await isar.writeTxn(() async {
          page.ocrStatus = OcrStatus.failed;
          await isar.pageEntitys.put(page);
        });

        ServicesLogger.error(
          'background',
          'Transient OCR failure for page ${page.pageId}',
          error: error,
          stackTrace: stackTrace,
        );
        return false;
      }
    }

    if (hasRemaining) {
      await Workmanager().registerOneOffTask(
        'ocr-index-task-$documentId',
        'ocr-index-task',
        inputData: <String, dynamic>{'documentId': documentId},
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );
      ServicesLogger.info(
        'background',
        'Re-queued OCR task for remaining pages of $documentId',
      );
    }

    ServicesLogger.info('background', 'OCR task completed for $documentId');
    return true;
  } finally {
    await ocrPipeline.dispose();
  }
}
