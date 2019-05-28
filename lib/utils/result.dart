/// Packs data+exception in Result object
class Result<T> {
  final T data;
  final Exception ex;

  factory Result.success(T d) {
    if (d != null) {
      return Result._(d, null);
    }
    return Result._(null, Exception("data is null for 'success factory'"));
  }

  factory Result.error(Exception e) {
    if (e != null) {
      return Result._(null, e);
    }
    return Result._(null, Exception("exception is null for 'error factory'"));
  }

  Result._([this.data, this.ex]);

}

