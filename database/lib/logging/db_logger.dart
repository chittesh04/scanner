import 'dart:developer' as developer;

class DbLogger {
  const DbLogger._();

  static void info(String message) {
    developer.log(
      '[INFO][db] $message',
      name: 'smartscan.db',
      level: 800,
    );
  }

  static void warn(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '[WARN][db] $message',
      name: 'smartscan.db',
      level: 900,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      '[ERROR][db] $message',
      name: 'smartscan.db',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
