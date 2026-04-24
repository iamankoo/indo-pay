class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.buildNumber,
    required this.forceUpdate,
    required this.apkUrl,
    required this.message,
    this.releaseNotes,
  });

  final String latestVersion;
  final int buildNumber;
  final bool forceUpdate;
  final String apkUrl;
  final String message;
  final String? releaseNotes;

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    return AppUpdateInfo(
      latestVersion: json['latest_version'] as String,
      buildNumber: json['build_number'] as int,
      forceUpdate: json['force_update'] as bool,
      apkUrl: json['apk_url'] as String,
      message: json['message'] as String,
      releaseNotes: json['release_notes'] as String?,
    );
  }
}
