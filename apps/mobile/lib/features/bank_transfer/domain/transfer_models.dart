class Beneficiary {
  const Beneficiary({
    required this.id,
    required this.beneficiaryName,
    required this.nickname,
    required this.ifsc,
    required this.bankName,
    required this.accountNumberMasked,
  });

  final String id;
  final String beneficiaryName;
  final String nickname;
  final String ifsc;
  final String bankName;
  final String accountNumberMasked;

  factory Beneficiary.fromJson(Map<String, dynamic> json) {
    return Beneficiary(
      id: json["id"]?.toString() ?? "",
      beneficiaryName: json["beneficiaryName"]?.toString() ?? "Beneficiary",
      nickname: json["nickname"]?.toString() ?? "Recent",
      ifsc: json["ifsc"]?.toString() ?? "",
      bankName: json["bankName"]?.toString() ?? "Bank",
      accountNumberMasked: json["accountNumberMasked"]?.toString() ?? "XXXX",
    );
  }
}

class TransferPreview {
  const TransferPreview({
    required this.amount,
    required this.bankAmount,
    required this.rail,
    required this.eta,
    required this.railReason,
  });

  final int amount;
  final int bankAmount;
  final String rail;
  final String eta;
  final String railReason;

  factory TransferPreview.fromJson(Map<String, dynamic> json) {
    return TransferPreview(
      amount: _asInt(json["amount"]),
      bankAmount: _asInt(json["bankAmount"]),
      rail: json["rail"]?.toString() ?? "SMART_QUICK",
      eta: json["eta"]?.toString() ?? "Pending",
      railReason: json["railReason"]?.toString() ?? "Route unavailable",
    );
  }
}

class TransferReceipt {
  const TransferReceipt({
    required this.transactionId,
    required this.status,
    required this.rail,
    required this.eta,
  });

  final String transactionId;
  final String status;
  final String rail;
  final String eta;

  factory TransferReceipt.fromJson(Map<String, dynamic> json) {
    return TransferReceipt(
      transactionId: json["transactionId"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "UNKNOWN",
      rail: json["rail"]?.toString() ?? "SMART_QUICK",
      eta: json["eta"]?.toString() ?? "Pending",
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
