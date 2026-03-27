sealed class Result<T> {
  const Result();

  R fold<R>({required R Function(T data) success, required R Function(Object error) failure});
}

class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;

  @override
  R fold<R>({required R Function(T data) success, required R Function(Object error) failure}) {
    return success(data);
  }
}

class Failure<T> extends Result<T> {
  const Failure(this.error);
  final Object error;

  @override
  R fold<R>({required R Function(T data) success, required R Function(Object error) failure}) {
    return failure(error);
  }
}
