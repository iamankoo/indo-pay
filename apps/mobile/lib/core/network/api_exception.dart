import "package:dio/dio.dart";

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  final String code;
  final String message;
  final int? statusCode;

  factory ApiException.fromDioError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      return ApiException(
        code: data["code"]?.toString() ?? "REQUEST_FAILED",
        message: data["message"]?.toString() ?? error.message ?? "Request failed",
        statusCode: error.response?.statusCode,
      );
    }

    return ApiException(
      code: "REQUEST_FAILED",
      message: error.message ?? "Something went wrong",
      statusCode: error.response?.statusCode,
    );
  }

  @override
  String toString() => "$code: $message";
}
