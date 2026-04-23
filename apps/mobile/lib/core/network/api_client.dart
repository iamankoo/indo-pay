import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../config/app_config.dart";
import "../storage/passbook_cache_store.dart";
import "../storage/session_store.dart";
import "auth_interceptor.dart";
import "retry_interceptor.dart";

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore();
});

final passbookCacheStoreProvider = Provider<PassbookCacheStore>((ref) {
  return PassbookCacheStore();
});

final apiClientProvider = Provider<Dio>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: const {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    ),
  );

  dio.interceptors.add(AuthInterceptor(dio: dio, sessionStore: sessionStore));
  dio.interceptors.add(RetryInterceptor(dio));

  return dio;
});
