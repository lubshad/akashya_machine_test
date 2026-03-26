import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class CalculatorsHomeScreen extends StatelessWidget {
  const CalculatorsHomeScreen({super.key});

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
                      'Calculators',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Text(
                  'Plan your financial future with precision',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  children: [
                    _buildCalcCard(
                      context,
                      'SIP Calculator',
                      'Plan your monthly investments to reach your goals.',
                      LucideIcons.refreshCw,
                      () => context.push('/calculators/sip'),
                    ),
                    _buildCalcCard(
                      context,
                      'Retirement Planner',
                      'Estimate the corpus you need for a comfortable retirement.',
                      LucideIcons.umbrella,
                      () => context.push('/calculators/retirement'),
                    ),
                    _buildCalcCard(
                      context,
                      'Lumpsum Calculator',
                      'See how much your one-time investment can grow.',
                      LucideIcons.briefcase,
                      () => context.push('/calculators/lumpsum'),
                    ),
                    _buildCalcCard(
                      context,
                      'Tax Saver (ELSS)',
                      'Calculate how much tax you can save with ELSS under 80C.',
                      LucideIcons.shield,
                      () => context.push('/calculators/tax-saver'),
                    ),
                    _buildCalcCard(
                      context,
                      'EMI Calculator',
                      'Calculate your EMI for home, car or personal loans.',
                      LucideIcons.calculator,
                      () => context.push('/calculators/emi'),
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

  Widget _buildCalcCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassDecoration,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                color: AppTheme.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
