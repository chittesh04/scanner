import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartscan/app/app.dart';
import 'package:flutter/material.dart';
import 'package:smartscan/core/di/service_locator.dart';
import 'package:smartscan/core/background/ocr_background_callback.dart';
import 'package:smartscan_services/background_tasks/work_manager_dispatcher.dart';

Future<void> bootstrap() async {
  await configureDependencies();
  await WorkManagerDispatcher.initialize(ocrBackgroundCallback);
  runApp(const ProviderScope(child: SmartScanApp()));
}
