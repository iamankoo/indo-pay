import "package:shared_preferences/shared_preferences.dart";

class SessionStore {
  static const _accessTokenKey = "session.accessToken";
  static const _refreshTokenKey = "session.refreshToken";
  static const _userIdKey = "session.userId";

  SharedPreferences? _preferences;

  Future<SharedPreferences> _instance() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> readAccessToken() async {
    final prefs = await _instance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await _instance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<String?> readUserId() async {
    final prefs = await _instance();
    return prefs.getString(_userIdKey);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    final prefs = await _instance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
  }

  Future<String?> readUserName() async {
    final prefs = await _instance();
    return prefs.getString("user.fullName");
  }

  Future<void> saveUserName({
    required String fullName,
    required String mobileNumber,
    required String email,
  }) async {
    final prefs = await _instance();
    await prefs.setString("user.fullName", fullName);
    await prefs.setString("user.mobileNumber", mobileNumber);
    await prefs.setString("user.email", email);
  }
}
