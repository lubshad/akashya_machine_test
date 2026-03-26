import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Services',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage all your financial needs in one place.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      _buildServiceSection('Investments & Savings'),
                      const SizedBox(height: 16),
                      _buildServiceItem(
                        context,
                        'Mutual Funds',
                        'Top performing funds',
                        LucideIcons.layers,
                        '/mutual-funds',
                      ),
                      _buildServiceItem(
                        context,
                        'Goal Planning',
                        'Smart goal tracker',
                        LucideIcons.target,
                        '/goals',
                      ),
                      _buildServiceItem(
                        context,
                        'Stock Portfolio',
                        'Direct equity tracking',
                        LucideIcons.trendingUp,
                        '/market-overview',
                      ),
                      const SizedBox(height: 32),
                      _buildServiceSection('Loans & Credit'),
                      const SizedBox(height: 16),
                      _buildServiceItem(
                        context,
                        'Personal Loan',
                        'Instant disbursal',
                        LucideIcons.user,
                        '/loans',
                      ),
                      _buildServiceItem(
                        context,
                        'Credit Score',
                        'Check for free',
                        LucideIcons.shieldCheck,
                        '/risk-profiling',
                      ),
                      const SizedBox(height: 32),
                      _buildServiceSection('Utilities'),
                      const SizedBox(height: 16),
                      _buildServiceItem(
                        context,
                        'Calculators',
                        'SIP & Finance tools',
                        LucideIcons.calculator,
                        '/calculators',
                      ),
                      _buildServiceItem(
                        context,
                        'Academy',
                        'Learn to invest',
                        LucideIcons.graduationCap,
                        '/academy',
                      ),
                      _buildServiceItem(
                        context,
                        'Tax Reports',
                        'Easy tax filing',
                        LucideIcons.fileText,
                        '/reports',
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
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Services Hub',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryAccentColor,
      ),
    );
  }

  Widget _buildServiceItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String route,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassDecoration,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(
          LucideIcons.chevronRight,
          color: AppTheme.textSecondary,
          size: 20,
        ),
        onTap: () => context.push(route),
      ),
    );
  }
}
