class MerchantDashboard {
  const MerchantDashboard({
    required this.merchantId,
    required this.businessName,
    required this.city,
    required this.kycStatus,
    required this.settlements,
  });

  final String merchantId;
  final String businessName;
  final String city;
  final String kycStatus;
  final List<SettlementItem> settlements;

  factory MerchantDashboard.fromJson(Map<String, dynamic> json) {
    return MerchantDashboard(
      merchantId: json["merchantId"]?.toString() ?? "",
      businessName: json["businessName"]?.toString() ?? "Merchant",
      city: json["city"]?.toString() ?? "Unknown",
      kycStatus: json["kycStatus"]?.toString() ?? "PENDING",
      settlements: _asList(json["settlements"]).map(SettlementItem.fromJson).toList(),
    );
  }
}

class SettlementItem {
  const SettlementItem({
    required this.businessDay,
    required this.grossSales,
    required this.netSettlement,
    required this.orders,
    required this.status,
  });

  final String businessDay;
  final int grossSales;
  final int netSettlement;
  final int orders;
  final String status;

  factory SettlementItem.fromJson(Map<String, dynamic> json) {
    return SettlementItem(
      businessDay: json["businessDay"]?.toString() ?? "",
      grossSales: _asInt(json["grossSales"]),
      netSettlement: _asInt(json["netSettlement"]),
      orders: _asInt(json["orders"]),
      status: json["status"]?.toString() ?? "UNKNOWN",
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

List<Map<String, dynamic>> _asList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
