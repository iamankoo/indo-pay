import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../domain/merchant_dashboard.dart";

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  return MerchantRepository(ref.watch(apiClientProvider));
});

final merchantDashboardProvider = FutureProvider<MerchantDashboard>((ref) async {
  return ref.watch(merchantRepositoryProvider).fetchDashboard();
});

class MerchantRepository {
  MerchantRepository(this._dio);

  final Dio _dio;

  Future<MerchantDashboard> fetchDashboard() async {
    final profileResponse = await _dio.get<Map<String, dynamic>>(
      "/merchants/${AppConfig.merchantDemoId}/profile",
    );
    final settlementsResponse = await _dio.get<Map<String, dynamic>>(
      "/merchants/${AppConfig.merchantDemoId}/settlements",
      queryParameters: {
        "days": 7,
      },
    );

    final profile = profileResponse.data ?? const <String, dynamic>{};
    final settlements = settlementsResponse.data?["items"] as List<dynamic>? ??
        const <dynamic>[];

    return MerchantDashboard(
      merchantId: profile["merchantId"]?.toString() ?? AppConfig.merchantDemoId,
      businessName: profile["businessName"]?.toString() ?? "Merchant",
      city: profile["city"]?.toString() ?? "Imphal",
      kycStatus: profile["kycStatus"]?.toString() ?? "PENDING",
      settlements: settlements
          .cast<Map<String, dynamic>>()
          .map(SettlementItem.fromJson)
          .toList(),
    );
  }

  Future<Map<String, dynamic>> createPaymentLink(int amount) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/merchants/${AppConfig.merchantDemoId}/payment-links",
      data: {
        "amount": amount,
        "title": "Counter collection",
      },
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> issueDynamicQr(int amount) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/merchants/qr",
      data: {
        "merchantId": AppConfig.merchantDemoId,
        "mode": "DYNAMIC",
        "amount": amount,
      },
      options: Options(
        headers: {
          "x-idempotency-key": "merchant-qr-$amount",
        },
      ),
    );
    return response.data ?? const <String, dynamic>{};
  }
}
