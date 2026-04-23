class PassbookPage {
  const PassbookPage({
    required this.tab,
    required this.page,
    required this.hasMore,
    this.nextPage,
    this.filters = const <String>[],
    this.items = const <PassbookEntry>[],
  });

  final String tab;
  final int page;
  final bool hasMore;
  final int? nextPage;
  final List<String> filters;
  final List<PassbookEntry> items;

  factory PassbookPage.fromJson(Map<String, dynamic> json) {
    return PassbookPage(
      tab: json["tab"]?.toString() ?? "all",
      page: _asInt(json["page"], fallback: 1),
      hasMore: json["hasMore"] == true,
      nextPage: json["nextPage"] == null ? null : _asInt(json["nextPage"]),
      filters: _asStringList(json["filters"]),
      items: _asList(json["items"]).map(PassbookEntry.fromJson).toList(),
    );
  }
}

class PassbookEntry {
  const PassbookEntry({
    required this.id,
    required this.type,
    required this.amount,
    this.direction,
    this.status,
    this.rail,
    this.referenceLabel,
    this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final String type;
  final int amount;
  final String? direction;
  final String? status;
  final String? rail;
  final String? referenceLabel;
  final DateTime? expiresAt;
  final DateTime createdAt;

  factory PassbookEntry.fromJson(Map<String, dynamic> json) {
    return PassbookEntry(
      id: json["id"]?.toString() ?? "",
      type: json["type"]?.toString() ?? "entry",
      amount: _asInt(
        json["amount"] ?? json["availableBalance"] ?? json["currentBalance"],
      ),
      direction: json["direction"]?.toString(),
      status: json["status"]?.toString(),
      rail: json["rail"]?.toString(),
      referenceLabel: json["referenceLabel"]?.toString() ?? json["description"]?.toString(),
      expiresAt: _asNullableDateTime(json["expiresAt"]),
      createdAt: _asDateTime(json["createdAt"]),
    );
  }
}

int _asInt(Object? value, {int fallback = 0}) {
  return switch (value) {
    int number => number,
    double number => number.round(),
    String text => int.tryParse(text) ?? fallback,
    _ => fallback,
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

List<String> _asStringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value.map((item) => item.toString()).toList(growable: false);
}

List<Map<String, dynamic>> _asList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }

  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}
