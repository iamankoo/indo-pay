import "package:shared_preferences/shared_preferences.dart";

class SessionStore {
  static const _accessTokenKey = "session.accessToken";
  static const _refreshTokenKey = "session.refreshToken";
  static const _userIdKey = "session.userId";
  static const _userFullNameKey = "user.fullName";
  static const _userMobileNumberKey = "user.mobileNumber";
  static const _userEmailKey = "user.email";
  static const _userProfilePhotoPathKey = "user.profilePhotoPath";

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
    return prefs.getString(_userFullNameKey);
  }

  Future<String?> readUserMobileNumber() async {
    final prefs = await _instance();
    return prefs.getString(_userMobileNumberKey);
  }

  Future<String?> readUserEmail() async {
    final prefs = await _instance();
    return prefs.getString(_userEmailKey);
  }

  Future<String?> readUserProfilePhotoPath() async {
    final prefs = await _instance();
    return prefs.getString(_userProfilePhotoPathKey);
  }

  Future<StoredUserProfile?> readUserProfile() async {
    final prefs = await _instance();
    final fullName = prefs.getString(_userFullNameKey);
    final mobileNumber = prefs.getString(_userMobileNumberKey);
    final email = prefs.getString(_userEmailKey);

    if (fullName == null || fullName.isEmpty) {
      return null;
    }

    return StoredUserProfile(
      fullName: fullName,
      mobileNumber: mobileNumber ?? "",
      email: email ?? "",
      profilePhotoPath: prefs.getString(_userProfilePhotoPathKey),
    );
  }

  Future<void> saveUserName({
    required String fullName,
    required String mobileNumber,
    required String email,
  }) async {
    await saveUserProfile(
      fullName: fullName,
      mobileNumber: mobileNumber,
      email: email,
      profilePhotoPath: await readUserProfilePhotoPath(),
    );
  }

  Future<void> saveUserProfile({
    required String fullName,
    required String mobileNumber,
    required String email,
    String? profilePhotoPath,
  }) async {
    final prefs = await _instance();
    await prefs.setString(_userFullNameKey, fullName);
    await prefs.setString(_userMobileNumberKey, mobileNumber);
    await prefs.setString(_userEmailKey, email);

    if (profilePhotoPath == null || profilePhotoPath.isEmpty) {
      await prefs.remove(_userProfilePhotoPathKey);
      return;
    }

    await prefs.setString(_userProfilePhotoPathKey, profilePhotoPath);
  }

  Future<void> saveUserProfilePhotoPath(String? profilePhotoPath) async {
    final prefs = await _instance();
    if (profilePhotoPath == null || profilePhotoPath.isEmpty) {
      await prefs.remove(_userProfilePhotoPathKey);
      return;
    }

    await prefs.setString(_userProfilePhotoPathKey, profilePhotoPath);
  }
}

class StoredUserProfile {
  const StoredUserProfile({
    required this.fullName,
    required this.mobileNumber,
    required this.email,
    this.profilePhotoPath,
  });

  final String fullName;
  final String mobileNumber;
  final String email;
  final String? profilePhotoPath;
}
