import "package:dio/dio.dart";

import "../config/app_config.dart";
import "../storage/session_store.dart";

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.dio,
    required this.sessionStore,
  });

  final Dio dio;
  final SessionStore sessionStore;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await sessionStore.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra["refreshRetried"] == true;

    if (statusCode != 401 || alreadyRetried) {
      handler.next(err);
      return;
    }

    final refreshToken = await sessionStore.readRefreshToken();
    final userId = await sessionStore.readUserId();
    if (refreshToken == null || userId == null) {
      handler.next(err);
      return;
    }

    try {
      final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final response = await refreshDio.post<Map<String, dynamic>>(
        "/auth/refresh",
        data: {
          "refreshToken": refreshToken,
        },
      );
      final payload = response.data ?? const <String, dynamic>{};
      final nextAccessToken = payload["sessionToken"]?.toString() ?? refreshToken;
      final nextRefreshToken = payload["refreshToken"]?.toString() ?? refreshToken;

      await sessionStore.saveSession(
        accessToken: nextAccessToken,
        refreshToken: nextRefreshToken,
        userId: userId,
      );

      final retryOptions = requestOptions.copyWith(
        headers: {
          ...requestOptions.headers,
          "Authorization": "Bearer $nextAccessToken",
        },
        extra: {
          ...requestOptions.extra,
          "refreshRetried": true,
        },
      );

      final retryResponse = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (refreshError) {
      handler.next(refreshError);
    }
  }
}
