class HomeDashboard {
  const HomeDashboard({
    required this.userId,
    required this.walletBalance,
    required this.cashbackEarnedThisMonth,
    required this.expiringRewards,
    required this.passbookPreview,
  });

  final String userId;
  final int walletBalance;
  final int cashbackEarnedThisMonth;
  final int expiringRewards;
  final List<HomeFeedItem> passbookPreview;

  factory HomeDashboard.fromJson(Map<String, dynamic> json) {
    return HomeDashboard(
      userId: json["userId"]?.toString() ?? "",
      walletBalance: _asInt(json["walletBalance"]),
      cashbackEarnedThisMonth: _asInt(json["cashbackEarnedThisMonth"]),
      expiringRewards: _asInt(json["expiringRewards"]),
      passbookPreview: _asList(json["passbookPreview"])
          .map(HomeFeedItem.fromJson)
          .toList(),
    );
  }
}

class HomeFeedItem {
  const HomeFeedItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String type;
  final int amount;
  final String status;
  final DateTime createdAt;

  factory HomeFeedItem.fromJson(Map<String, dynamic> json) {
    return HomeFeedItem(
      id: json["id"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "transaction",
      amount: _asInt(json["amount"]),
      status: json["status"]?.toString() ?? "SUCCESS",
      createdAt: _asDateTime(json["createdAt"]),
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

DateTime _asDateTime(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  return DateTime.now();
}

List<Map<String, dynamic>> _asList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
