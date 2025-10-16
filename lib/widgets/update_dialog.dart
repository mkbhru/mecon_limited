import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/version_info.dart';

class UpdateDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  final String currentVersion;
  final bool forceUpdate;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    required this.currentVersion,
    required this.forceUpdate,
  });

  Future<void> _launchUpdateUrl(BuildContext context) async {
    try {
      debugPrint('🔗 [UpdateDialog] Launching update URL: ${versionInfo.updateUrl}');

      final uri = Uri.parse(versionInfo.updateUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('✅ [UpdateDialog] Successfully launched update URL');
      } else {
        debugPrint('❌ [UpdateDialog] Could not launch URL: ${versionInfo.updateUrl}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open update link'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [UpdateDialog] Error launching URL: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Prevent dismissing if force update
      canPop: !forceUpdate,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              forceUpdate ? Icons.warning : Icons.info_outline,
              color: forceUpdate ? Colors.orange : Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                forceUpdate ? 'Update Required' : 'Update Available',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (forceUpdate)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.priority_high, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This update is mandatory to continue using the app.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              '⚠️ Your app version is outdated.\nRunning old versions may cause crashes, data sync failures, or security vulnerabilities.\nUpdate now to stay protected and ensure uninterrupted access.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildVersionRow('Current Version', currentVersion, Colors.grey[700]!),
                  const SizedBox(height: 8),
                  _buildVersionRow('Latest Version', versionInfo.latestVersion, Colors.blue[700]!),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!forceUpdate)
            TextButton(
              onPressed: () {
                debugPrint('❌ [UpdateDialog] User dismissed optional update');
                Navigator.of(context).pop();
              },
              child: Text(
                'Later',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                ),
              ),
            ),
          ElevatedButton.icon(
            onPressed: () => _launchUpdateUrl(context),
            icon: const Icon(Icons.system_update, color: Colors.white),
            label: const Text(
              'Update Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: forceUpdate ? Colors.orange : Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, String version, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        Text(
          version,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
