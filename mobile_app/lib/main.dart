import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:smartscan/core/logging/app_logger.dart';
import 'app/bootstrap.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      AppLogger.error(
        'global',
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.error(
        'global',
        'Uncaught platform error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };

    await bootstrap();
  }, (error, stack) {
    AppLogger.error(
      'global',
      'Uncaught zone error',
      error: error,
      stackTrace: stack,
    );
  });
}
