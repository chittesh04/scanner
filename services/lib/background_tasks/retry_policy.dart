import 'dart:async';

class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 250),
  });

  final int maxAttempts;
  final Duration initialDelay;

  Future<T> run<T>(Future<T> Function() operation) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        if (attempt == maxAttempts) break;
        final backoffFactor = 1 << (attempt - 1);
        final delay = initialDelay * backoffFactor;
        await Future<void>.delayed(delay);
      }
    }

    if (lastError == null || lastStackTrace == null) {
      throw StateError('RetryPolicy failed without a captured exception.');
    }
    Error.throwWithStackTrace(lastError, lastStackTrace);
  }
}
