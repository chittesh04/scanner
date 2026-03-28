import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/app/app.dart';
import 'package:flutter/material.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smartscan_services/background_tasks/ocr_background_callback.dart';
import 'package:smartscan_services/background_tasks/work_manager_dispatcher.dart';

Future<void> bootstrap() async {
  await configureDependencies();

  // Orphan Cleanup: Destroy any unencrypted ML Kit files left by a hard SIGKILL memory crash
  try {
    final tempDir = await getTemporaryDirectory();
    if (tempDir.existsSync()) {
      for (final file in tempDir.listSync()) {
        if (file is File && file.path.endsWith('_mlkit_tmp.jpg')) {
          try {
            file.deleteSync();
          } catch (_) {}
        }
      }
    }
  } catch (_) {}

  await WorkManagerDispatcher.initialize(ocrBackgroundCallback);
  runApp(const ProviderScope(child: SmartScanApp()));
}
