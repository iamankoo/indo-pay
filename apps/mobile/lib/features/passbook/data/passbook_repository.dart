import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../../../core/storage/passbook_cache_store.dart";
import "../domain/passbook_page.dart";

final passbookRepositoryProvider = Provider<PassbookRepository>((ref) {
  return PassbookRepository(
    dio: ref.watch(apiClientProvider),
    cacheStore: ref.watch(passbookCacheStoreProvider),
  );
});

class PassbookRepository {
  PassbookRepository({
    required Dio dio,
    required PassbookCacheStore cacheStore,
  })  : _dio = dio,
        _cacheStore = cacheStore;

  final Dio _dio;
  final PassbookCacheStore _cacheStore;

  Future<PassbookPage> fetchPassbook({
    int page = 1,
    String? category,
  }) async {
    final cacheKey = "page-$page-${category ?? "all"}";
    final cached = await _cacheStore.read(cacheKey);
    if (cached != null && page == 1) {
      return PassbookPage.fromJson(cached);
    }

    final response = await _dio.get<Map<String, dynamic>>(
      "/passbook",
      queryParameters: {
        "userId": AppConfig.defaultUserId,
        "page": page,
        if (category != null && category.isNotEmpty) "category": category,
      },
    );
    final payload = response.data ?? const <String, dynamic>{};
    await _cacheStore.save(cacheKey, payload);
    return PassbookPage.fromJson(payload);
  }

  Future<String> exportStatement({
    required DateTime fromDate,
    required DateTime toDate,
    String format = "CSV",
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/passbook/export",
      data: {
        "userId": AppConfig.defaultUserId,
        "fromDate": fromDate.toUtc().toIso8601String(),
        "toDate": toDate.toUtc().toIso8601String(),
        "format": format,
      },
    );

    final payload = response.data ?? const <String, dynamic>{};
    return payload["fileUrl"]?.toString() ?? "";
  }
}
