import "package:dio/dio.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../core/config/app_config.dart";
import "../../../core/network/api_client.dart";
import "../domain/transfer_models.dart";

final bankTransferRepositoryProvider = Provider<BankTransferRepository>((ref) {
  return BankTransferRepository(ref.watch(apiClientProvider));
});

final recentBeneficiariesProvider = FutureProvider<List<Beneficiary>>((ref) async {
  return ref.watch(bankTransferRepositoryProvider).fetchBeneficiaries();
});

class BankTransferRepository {
  BankTransferRepository(this._dio);

  final Dio _dio;

  Future<List<Beneficiary>> fetchBeneficiaries() async {
    final response = await _dio.get<List<dynamic>>(
      "/bank-transfers/beneficiaries",
      queryParameters: {
        "userId": AppConfig.defaultUserId,
      },
    );

    return (response.data ?? const <dynamic>[])
        .cast<Map<String, dynamic>>()
        .map(Beneficiary.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> fetchBeneficiaryName({
    required String accountNumber,
    required String ifsc,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/bank-transfers/name-enquiry",
      data: {
        "accountNumber": accountNumber,
        "ifsc": ifsc,
      },
    );
    return response.data ?? const <String, dynamic>{};
  }

  Future<Map<String, dynamic>> validateIfsc(String ifsc) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/bank-transfers/validate-ifsc",
      data: {
        "ifsc": ifsc,
      },
    );

    return response.data ?? const <String, dynamic>{};
  }

  Future<TransferPreview> previewTransfer({
    required int amount,
    String rail = "SMART_QUICK",
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/bank-transfers/preview",
      data: {
        "amount": amount,
        "rail": rail,
      },
    );
    return TransferPreview.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<TransferReceipt> submitTransfer({
    required String accountNumber,
    required String ifsc,
    required String beneficiaryName,
    required String nickname,
    required int amount,
    required String rail,
    required String idempotencyKey,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      "/bank-transfers/transfer",
      data: {
        "userId": AppConfig.defaultUserId,
        "accountNumber": accountNumber,
        "ifsc": ifsc,
        "beneficiaryName": beneficiaryName,
        "nickname": nickname,
        "amount": amount,
        "rail": rail,
      },
      options: Options(
        headers: {
          "x-idempotency-key": idempotencyKey,
        },
      ),
    );
    return TransferReceipt.fromJson(response.data ?? const <String, dynamic>{});
  }
}
