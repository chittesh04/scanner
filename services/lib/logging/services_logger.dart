import 'dart:developer' as developer;

class ServicesLogger {
  const ServicesLogger._();

  static void info(String feature, String message) {
    developer.log(
      '[INFO][$feature] $message',
      name: 'smartscan.services.$feature',
      level: 800,
    );
  }

  static void warn(
    String feature,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      '[WARN][$feature] $message',
      name: 'smartscan.services.$feature',
      level: 900,
      error: error,
      stackTrace: stackTrace,
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
      name: 'smartscan.services.$feature',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
