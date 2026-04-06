import 'dart:developer' as developer;

class EngineLogger {
  const EngineLogger._();

  static void info(String feature, String message) {
    developer.log(
      '[INFO][$feature] $message',
      name: 'smartscan.engine.$feature',
      level: 800,
    );
  }

  static void error(
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[ERROR][$feature] $message',
      name: 'smartscan.engine.$feature',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
