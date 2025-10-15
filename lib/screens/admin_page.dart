import 'package:flutter/material.dart';
import '../services/user_preferences_manager.dart';
import 'admin/mantra_attendance.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _prefsManager = UserPreferencesManager.instance;
  String _userName = '';
  String _persNo = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = _prefsManager.currentUser;
    if (mounted) {
      setState(() {
        _userName = user?.fullName ?? 'Admin';
        _persNo = user?.persNo ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.shade700,
              Colors.red.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section - Compact Version
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Admin Panel',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_persNo.isNotEmpty)
                            Text(
                              'ID: $_persNo',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Admin Features Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Administrative Tools',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage and monitor MECON operations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Attendance Management Section
                        _buildSectionTitle('Attendance Management'),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.fingerprint,
                          title: 'Mantra Attendance',
                          subtitle: 'View employee punch records',
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MantraAttendanceScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.calendar_month,
                          title: 'Attendance Reports',
                          subtitle: 'Generate monthly reports',
                          color: Colors.teal,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),

                        const SizedBox(height: 24),

                        // User Management Section
                        _buildSectionTitle('User Management'),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.people,
                          title: 'Manage Users',
                          subtitle: 'Add, edit, or remove users',
                          color: Colors.orange,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.security,
                          title: 'Roles & Permissions',
                          subtitle: 'Configure access control',
                          color: Colors.purple,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),

                        const SizedBox(height: 24),

                        // Reports & Analytics Section
                        _buildSectionTitle('Reports & Analytics'),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.assessment,
                          title: 'System Reports',
                          subtitle: 'View usage statistics',
                          color: Colors.green,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.analytics,
                          title: 'Analytics Dashboard',
                          subtitle: 'Monitor app performance',
                          color: Colors.indigo,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),

                        const SizedBox(height: 24),

                        // System Configuration Section
                        _buildSectionTitle('System Configuration'),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.settings,
                          title: 'System Settings',
                          subtitle: 'Configure app parameters',
                          color: Colors.blueGrey,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildAdminCard(
                          icon: Icons.notifications_active,
                          title: 'Notifications',
                          subtitle: 'Send announcements',
                          color: Colors.amber,
                          onTap: () {
                            _showComingSoon();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
