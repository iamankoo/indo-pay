class PaymentPreview {
  const PaymentPreview({
    required this.walletUse,
    required this.bankAmount,
  });

  final int walletUse;
  final int bankAmount;

  factory PaymentPreview.fromJson(Map<String, dynamic> json) {
    return PaymentPreview(
      walletUse: _asInt(json["walletUse"]),
      bankAmount: _asInt(json["bankAmount"]),
    );
  }
}

class PaymentReceipt {
  const PaymentReceipt({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.bankAmount,
    required this.walletAmount,
    this.cashbackAmount,
    this.cashbackExpiresAt,
    this.referenceHash,
  });

  final String transactionId;
  final String status;
  final int amount;
  final int bankAmount;
  final int walletAmount;
  final int? cashbackAmount;
  final DateTime? cashbackExpiresAt;
  final String? referenceHash;

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    final cashback = _asMap(json["cashback"]);

    return PaymentReceipt(
      transactionId: json["transactionId"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "UNKNOWN",
      amount: _asInt(json["amount"]),
      bankAmount: _asInt(json["bankAmount"]),
      walletAmount: _asInt(json["walletAmount"]),
      cashbackAmount: cashback.isEmpty ? null : _asInt(cashback["cashbackAmount"]),
      cashbackExpiresAt: cashback.isEmpty ? null : _asDateTime(cashback["expiresAt"]),
      referenceHash: json["referenceHash"]?.toString(),
    );
  }
}

int _asInt(Object? value) {
  return switch (value) {
    int number => number,
    double number => number.round(),
    String text => int.tryParse(text) ?? 0,
    _ => 0,
  };
}

DateTime? _asDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

Map<String, dynamic> _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : const <String, dynamic>{};
}
