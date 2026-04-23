import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

class PassbookCacheStore {
  SharedPreferences? _preferences;

  Future<SharedPreferences> _instance() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> save(String cacheKey, Map<String, dynamic> json) async {
    final prefs = await _instance();
    await prefs.setString("passbook.$cacheKey", jsonEncode(json));
  }

  Future<Map<String, dynamic>?> read(String cacheKey) async {
    final prefs = await _instance();
    final rawValue = prefs.getString("passbook.$cacheKey");
    if (rawValue == null) {
      return null;
    }

    return jsonDecode(rawValue) as Map<String, dynamic>;
  }
}
