import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _biometric = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.chevronLeft,
                        color: Colors.white,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    _buildSettingsGroup('Preferences', [
                      _SettingsItem(
                        LucideIcons.bell,
                        'Notifications',
                        true,
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                      ),
                      _SettingsItem(
                        LucideIcons.fingerprint,
                        'Biometric Login',
                        true,
                        value: _biometric,
                        onChanged: (v) => setState(() => _biometric = v),
                      ),
                      _SettingsItem(
                        LucideIcons.moon,
                        'Dark Mode',
                        true,
                        value: _darkMode,
                        onChanged: (v) => setState(() => _darkMode = v),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSettingsGroup('Security', [
                      _SettingsItem(
                        LucideIcons.lock,
                        'Change MPIN',
                        false,
                        onTap: () => _showComingSoon('Change MPIN'),
                      ),
                      _SettingsItem(
                        LucideIcons.shield,
                        'Two-Factor Authentication',
                        false,
                        onTap: () => _showComingSoon('2FA Settings'),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSettingsGroup('Privacy', [
                      _SettingsItem(
                        LucideIcons.eye,
                        'Data Sharing',
                        false,
                        onTap: () => _showComingSoon('Data Sharing Settings'),
                      ),
                      _SettingsItem(
                        LucideIcons.barChart2,
                        'Usage Analytics',
                        false,
                        onTap: () => _showComingSoon('Analytics Settings'),
                      ),
                      _SettingsItem(
                        LucideIcons.trash2,
                        'Delete Account',
                        false,
                        onTap: () => _showComingSoon('Delete Account'),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildSettingsGroup('About', [
                      _SettingsItem(
                        LucideIcons.info,
                        'Version 1.0.0',
                        false,
                        onTap: () => _showComingSoon('Version Info'),
                      ),
                      _SettingsItem(
                        LucideIcons.fileText,
                        'Terms & Conditions',
                        false,
                        onTap: () => _showComingSoon('Terms & Conditions'),
                      ),
                      _SettingsItem(
                        LucideIcons.shield,
                        'Privacy Policy',
                        false,
                        onTap: () => _showComingSoon('Privacy Policy'),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    // Logout button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          LucideIcons.logOut,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        title: const Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1E2A3A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Log Out',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              content: const Text(
                                'Are you sure you want to log out?',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    context.go('/welcome');
                                  },
                                  child: const Text('Log Out'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppTheme.surfaceColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<_SettingsItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: AppTheme.glassDecoration,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, size: 20),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: item.isSwitch
                        ? Switch(
                            value: item.value,
                            onChanged: item.onChanged,
                            activeThumbColor: AppTheme.primaryColor,
                          )
                        : const Icon(LucideIcons.chevronRight, size: 18),
                    onTap: item.onTap,
                  ),
                  if (index < items.length - 1)
                    const Divider(height: 1, indent: 56, color: Colors.white10),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final bool isSwitch;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;

  _SettingsItem(
    this.icon,
    this.title,
    this.isSwitch, {
    this.value = false,
    this.onChanged,
    this.onTap,
  });
}
