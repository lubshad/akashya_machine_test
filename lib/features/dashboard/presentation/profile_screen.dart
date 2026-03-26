import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../onboarding/bloc/auth_bloc.dart';
import '../../onboarding/bloc/auth_event.dart';
import 'dashboard_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildProfileSection([
                        _ProfileItem(
                          LucideIcons.user,
                          'Personal Information',
                          () => context.push('/personal-info'),
                        ),
                        _ProfileItem(
                          LucideIcons.landmark,
                          'Bank Account Details',
                          () => context.push('/bank-linking'),
                        ),
                        _ProfileItem(
                          LucideIcons.shieldCheck,
                          'KYC Status',
                          () => context.push('/aadhaar-kyc'),
                          subtitle: '✓ Verified',
                        ),
                        _ProfileItem(
                          LucideIcons.users,
                          'Nominee Management',
                          () => context.push('/nominees'),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildProfileSection([
                        _ProfileItem(
                          LucideIcons.history,
                          'Transaction History',
                          () => context.push('/transactions'),
                        ),
                        _ProfileItem(
                          LucideIcons.fileText,
                          'Portfolio Reports',
                          () => context.push('/reports'),
                        ),
                        _ProfileItem(
                          LucideIcons.helpCircle,
                          'Help & Support',
                          () => context.push('/help'),
                        ),
                        _ProfileItem(
                          LucideIcons.settings,
                          'Settings',
                          () => context.push('/settings'),
                        ),
                      ]),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2),
                          ),
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
                          onTap: () => _confirmLogout(context),
                          trailing: const Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const Text(
            'My Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.settings,
              color: AppTheme.primaryColor,
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              LucideIcons.user,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            FirebaseAuth.instance.currentUser?.displayName ?? displayName(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            FirebaseAuth.instance.currentUser?.email ?? 'No email available',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.shieldCheck,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'KYC Verified',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out of your Finvestea account?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(List<_ProfileItem> items) {
    return Container(
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppTheme.primaryColor,
                    size: 18,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      )
                    : null,
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                onTap: item.onTap,
              ),
              if (index < items.length - 1)
                const Divider(height: 1, indent: 56, color: Colors.white10),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  _ProfileItem(this.icon, this.title, this.onTap, {this.subtitle});
}
