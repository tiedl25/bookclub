class Result<T> {
  final T? value;
  final String? message;
  final bool isSuccess;

  Result.success(this.message, [this.value]) : isSuccess = true;
  Result.failure(this.message) : value = null, isSuccess = false;
}