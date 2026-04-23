import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../domain/payment_models.dart";

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(apiClientProvider));
});

class PaymentsRepository {
  PaymentsRepository(this._dio);

  final Dio _dio;

  Future<PaymentPreview> previewSplit(int amount) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/wallet/preview-redemption",
      data: {
        "transactionAmount": amount,
        "userId": AppConfig.defaultUserId,
      },
    );
    return PaymentPreview.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<PaymentReceipt> pay({
    required int amount,
    required String category,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/payments/pay",
      data: {
        "userId": AppConfig.defaultUserId,
        "merchantId": AppConfig.merchantDemoId,
        "amount": amount,
        "category": category,
        "rail": "UPI",
      },
      options: Options(
        headers: {
          "x-idempotency-key": idempotencyKey,
        },
      ),
    );
    return PaymentReceipt.fromJson(response.data ?? const <String, dynamic>{});
  }
}
