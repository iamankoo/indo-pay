import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../domain/app_update_info.dart';

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return UpdateRepository(Dio());
});

class UpdateRepository {
  UpdateRepository(this._dio);

  final Dio _dio;

  Future<AppUpdateInfo?> checkUpdate() async {
    try {
      final response = await _dio.getUri(_latestReleaseUri);
      if (response.statusCode == 200 && response.data != null) {
        return AppUpdateInfo.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {
      // Continue without blocking startup if release metadata is unavailable.
    }
    return null;
  }

  Uri get _latestReleaseUri {
    final apiBaseUri = Uri.parse(AppConfig.apiBaseUrl);
    return apiBaseUri.replace(
      pathSegments: [
        ...apiBaseUri.pathSegments,
        'releases',
        'latest',
      ],
    );
  }

  Future<bool> shouldShowUpdate(AppUpdateInfo info) async {
    final packageInfo = await PackageInfo.fromPlatform();
    
    // Semantic Version Comparison
    // e.g. 1.10.0 > 1.2.0
    final currentParts = packageInfo.version.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestParts = info.latestVersion.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    while (currentParts.length < 3) {
      currentParts.add(0);
    }
    while (latestParts.length < 3) {
      latestParts.add(0);
    }

    bool isNewerVersion = false;
    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) {
        isNewerVersion = true;
        break;
      } else if (latestParts[i] < currentParts[i]) {
        break;
      }
    }

    // Also check build number if versions match
    if (!isNewerVersion && latestParts.join('.') == currentParts.join('.')) {
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;
      if (info.buildNumber > currentBuild) {
        isNewerVersion = true;
      }
    }

    if (!isNewerVersion) {
      return false;
    }

    if (info.forceUpdate) {
      return true;
    }

    // Check if dismissed explicitly
    final prefs = await SharedPreferences.getInstance();
    final dismissedVersion = prefs.getString('dismissed_update_version');
    if (dismissedVersion == info.latestVersion) {
      return false; // Already dismissed this version
    }

    return true;
  }

  Future<void> dismissUpdate(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dismissed_update_version', version);
  }
}
