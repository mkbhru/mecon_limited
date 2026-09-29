import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../models/version_info.dart';
import '../utils/constants.dart';
import '../utils/app_constants.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  static UpdateService get instance => _instance;

  /// Fetch version info from backend
  Future<VersionInfo?> checkForUpdates() async {
    try {
      debugPrint('🔄 [UpdateService] Checking for updates...');

      final url = Uri.parse('$API_BASE_URL$updateCheckEndpoint');
      debugPrint('📡 [UpdateService] URL: $url');

      final response = await http.get(url, headers: apiHeaders()).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ [UpdateService] Request timed out');
          throw Exception('Connection timeout');
        },
      );

      debugPrint('📥 [UpdateService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        debugPrint('📦 [UpdateService] Response data: $jsonData');

        final versionInfo = VersionInfo.fromJson(jsonData);
        debugPrint('✅ [UpdateService] Parsed version info: $versionInfo');

        return versionInfo;
      } else {
        debugPrint('❌ [UpdateService] Failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [UpdateService] Error checking for updates: $e');
      return null;
    }
  }

  /// Get current app version
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version;
      debugPrint('📱 [UpdateService] Current app version: $version');
      return version;
    } catch (e) {
      debugPrint('❌ [UpdateService] Error getting app version: $e');
      return '0.0.0';
    }
  }

  /// Compare version strings (e.g., "1.2.3" vs "1.3.0")
  int compareVersions(String version1, String version2) {
    try {
      final v1Parts = version1.split('.').map(int.parse).toList();
      final v2Parts = version2.split('.').map(int.parse).toList();

      // Pad shorter version with zeros
      while (v1Parts.length < v2Parts.length) {
        v1Parts.add(0);
      }
      while (v2Parts.length < v1Parts.length) {
        v2Parts.add(0);
      }

      // Compare each part
      for (int i = 0; i < v1Parts.length; i++) {
        if (v1Parts[i] < v2Parts[i]) {
          return -1; // version1 < version2
        } else if (v1Parts[i] > v2Parts[i]) {
          return 1; // version1 > version2
        }
      }

      return 0; // versions are equal
    } catch (e) {
      debugPrint('❌ [UpdateService] Error comparing versions: $e');
      return 0;
    }
  }

  /// Check if update is needed
  Future<UpdateCheckResult> shouldShowUpdateDialog() async {
    try {
      debugPrint('🔍 [UpdateService] Starting update check...');

      final currentVersion = await getCurrentVersion();
      final versionInfo = await checkForUpdates();

      if (versionInfo == null) {
        debugPrint('⚠️ [UpdateService] No version info available');
        return UpdateCheckResult(
          showDialog: false,
          forceUpdate: false,
          versionInfo: null,
          currentVersion: currentVersion,
        );
      }

      // Check if current version is below minimum supported
      final comparedToMin = compareVersions(currentVersion, versionInfo.minSupportedVersion);
      final comparedToLatest = compareVersions(currentVersion, versionInfo.latestVersion);

      debugPrint('📊 [UpdateService] Version comparison:');
      debugPrint('   Current: $currentVersion');
      debugPrint('   Latest: ${versionInfo.latestVersion}');
      debugPrint('   Min Supported: ${versionInfo.minSupportedVersion}');
      debugPrint('   Compared to Latest: $comparedToLatest');
      debugPrint('   Compared to Min: $comparedToMin');

      // Force update if below minimum supported version
      if (comparedToMin < 0) {
        debugPrint('⚠️ [UpdateService] Below minimum supported version - FORCE UPDATE');
        return UpdateCheckResult(
          showDialog: true,
          forceUpdate: true,
          versionInfo: versionInfo,
          currentVersion: currentVersion,
        );
      }

      // Optional update if below latest version
      if (comparedToLatest < 0) {
        debugPrint('ℹ️ [UpdateService] Update available (optional: ${!versionInfo.forceUpdate})');
        return UpdateCheckResult(
          showDialog: true,
          forceUpdate: versionInfo.forceUpdate,
          versionInfo: versionInfo,
          currentVersion: currentVersion,
        );
      }

      debugPrint('✅ [UpdateService] App is up to date');
      return UpdateCheckResult(
        showDialog: false,
        forceUpdate: false,
        versionInfo: versionInfo,
        currentVersion: currentVersion,
      );
    } catch (e) {
      debugPrint('❌ [UpdateService] Error in shouldShowUpdateDialog: $e');
      return UpdateCheckResult(
        showDialog: false,
        forceUpdate: false,
        versionInfo: null,
        currentVersion: '0.0.0',
      );
    }
  }
}

class UpdateCheckResult {
  final bool showDialog;
  final bool forceUpdate;
  final VersionInfo? versionInfo;
  final String currentVersion;

  UpdateCheckResult({
    required this.showDialog,
    required this.forceUpdate,
    required this.versionInfo,
    required this.currentVersion,
  });
}
