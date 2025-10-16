import 'package:flutter/foundation.dart';

class VersionInfo {
  final String latestVersion;
  final String minSupportedVersion;
  final String updateUrl;
  final bool forceUpdate;

  VersionInfo({
    required this.latestVersion,
    required this.minSupportedVersion,
    required this.updateUrl,
    required this.forceUpdate,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    try {
      // Support both snake_case and lowercase formats
      final latestVersion = (json['latest_version'] ?? json['latestversion']) as String? ?? '0.0.0';
      final minSupportedVersion = (json['min_supported_version'] ?? json['minsupportedversion']) as String? ?? '0.0.0';
      final updateUrl = (json['update_url'] ?? json['updateurl']) as String? ?? '';
      final forceUpdate = json['force_update'] as bool? ?? false;

      debugPrint('📝 [VersionInfo] Parsed from JSON:');
      debugPrint('   Latest Version: $latestVersion');
      debugPrint('   Min Supported: $minSupportedVersion');
      debugPrint('   Update URL: $updateUrl');
      debugPrint('   Force Update: $forceUpdate');

      return VersionInfo(
        latestVersion: latestVersion,
        minSupportedVersion: minSupportedVersion,
        updateUrl: updateUrl,
        forceUpdate: forceUpdate,
      );
    } catch (e) {
      debugPrint('❌ [VersionInfo] Error parsing JSON: $e');
      return VersionInfo(
        latestVersion: '0.0.0',
        minSupportedVersion: '0.0.0',
        updateUrl: '',
        forceUpdate: false,
      );
    }
  }

  @override
  String toString() {
    return 'VersionInfo(latestVersion: $latestVersion, minSupportedVersion: $minSupportedVersion, forceUpdate: $forceUpdate)';
  }
}
