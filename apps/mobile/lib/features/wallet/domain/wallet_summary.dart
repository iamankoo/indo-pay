class WalletSummary {
  const WalletSummary({
    required this.userId,
    required this.promoWalletBalance,
    required this.expiringIn7Days,
    required this.monthlyRedeemed,
    required this.monthlyExpired,
    required this.redemptionUsageMeter,
    required this.rewardExpiryChips,
    required this.upcomingExpiries,
  });

  final String userId;
  final int promoWalletBalance;
  final int expiringIn7Days;
  final int monthlyRedeemed;
  final int monthlyExpired;
  final RedemptionUsageMeter redemptionUsageMeter;
  final List<RewardExpiryChip> rewardExpiryChips;
  final List<RewardExpiryChip> upcomingExpiries;

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      userId: json["userId"]?.toString() ?? "",
      promoWalletBalance: _asInt(json["promoWalletBalance"]),
      expiringIn7Days: _asInt(json["expiringIn7Days"]),
      monthlyRedeemed: _asInt(json["monthlyRedeemed"]),
      monthlyExpired: _asInt(json["monthlyExpired"]),
      redemptionUsageMeter: RedemptionUsageMeter.fromJson(
        _asMap(json["redemptionUsageMeter"]),
      ),
      rewardExpiryChips: _asList(json["rewardExpiryChips"])
          .map(RewardExpiryChip.fromJson)
          .toList(),
      upcomingExpiries: _asList(json["upcomingExpiries"])
          .map(RewardExpiryChip.fromJson)
          .toList(),
    );
  }
}

class RedemptionUsageMeter {
  const RedemptionUsageMeter({
    required this.capPercent,
    required this.consumedThisMonth,
    required this.burnThisMonth,
    required this.availableBalance,
  });

  final double capPercent;
  final int consumedThisMonth;
  final int burnThisMonth;
  final int availableBalance;

  factory RedemptionUsageMeter.fromJson(Map<String, dynamic> json) {
    return RedemptionUsageMeter(
      capPercent: _asDouble(json["capPercent"]),
      consumedThisMonth: _asInt(json["consumedThisMonth"]),
      burnThisMonth: _asInt(json["burnThisMonth"]),
      availableBalance: _asInt(json["availableBalance"]),
    );
  }
}

class RewardExpiryChip {
  const RewardExpiryChip({
    required this.id,
    required this.amount,
    required this.expiresAt,
    required this.label,
    this.description,
  });

  final String id;
  final int amount;
  final DateTime? expiresAt;
  final String label;
  final String? description;

  factory RewardExpiryChip.fromJson(Map<String, dynamic> json) {
    final expiresAt = _asNullableDateTime(json["expiresAt"]);
    final description = json["description"]?.toString();

    return RewardExpiryChip(
      id: json["id"]?.toString() ?? "",
      amount: _asInt(json["amount"]),
      expiresAt: expiresAt,
      label: json["label"]?.toString() ??
          (expiresAt == null ? "Open credit" : "Expires ${expiresAt.day}/${expiresAt.month}"),
      description: description,
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

double _asDouble(Object? value) {
  return switch (value) {
    int number => number.toDouble(),
    double number => number,
    String text => double.tryParse(text) ?? 0,
    _ => 0,
  };
}

DateTime? _asNullableDateTime(Object? value) {
  if (value == null) {
    return null;
  }

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

List<Map<String, dynamic>> _asList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
