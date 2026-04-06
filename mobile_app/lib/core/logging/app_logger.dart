import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger._();

  static void debug(String feature, String message, {Object? error}) {
    _log(LogLevel.debug, feature, message, error: error);
  }

  static void info(String feature, String message, {Object? error}) {
    _log(LogLevel.info, feature, message, error: error);
  }

  static void warn(String feature, String message, {Object? error}) {
    _log(LogLevel.warning, feature, message, error: error);
  }

  static void error(
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      feature,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    LogLevel level,
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final tag = '[${level.name.toUpperCase()}][$feature]';
    developer.log(
      '$tag $message',
      name: 'smartscan.$feature',
      error: error,
      stackTrace: stackTrace,
      level: _devLevel(level),
    );

    if (kDebugMode && error != null) {
      debugPrint('$tag error=$error');
    }
  }

  static int _devLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
