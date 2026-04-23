import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../domain/wallet_summary.dart";

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(apiClientProvider));
});

final walletSummaryProvider = FutureProvider<WalletSummary>((ref) async {
  return ref.watch(walletRepositoryProvider).fetchWalletSummary();
});

class WalletRepository {
  WalletRepository(this._dio);

  final Dio _dio;

  Future<WalletSummary> fetchWalletSummary() async {
    final response = await _dio.get<Map<String, dynamic>>(
      "/wallet/${AppConfig.defaultUserId}",
    );
    return WalletSummary.fromJson(response.data ?? const <String, dynamic>{});
  }
}
