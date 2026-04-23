import "dart:async";

import "package:dio/dio.dart";

class RetryInterceptor extends Interceptor {
  RetryInterceptor(this.dio);

  final Dio dio;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final retryCount = (requestOptions.extra["retryCount"] as int?) ?? 0;
    final shouldRetry = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (!shouldRetry || retryCount >= 2) {
      handler.next(err);
      return;
    }

    await Future<void>.delayed(Duration(milliseconds: 250 * (retryCount + 1)));
    final nextOptions = requestOptions.copyWith(
      extra: {
        ...requestOptions.extra,
        "retryCount": retryCount + 1,
      },
    );

    try {
      final response = await dio.fetch<dynamic>(nextOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
