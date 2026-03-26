import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class LoansHomeScreen extends StatelessWidget {
  const LoansHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 16),
                _buildHeroSection(context),
                const SizedBox(height: 32),
                const Text(
                  'Available Loan Products',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildLoanTypeCard(
                  context,
                  'Personal Loan',
                  'Up to ₹ 40 Lakhs',
                  '10.5% p.a',
                  LucideIcons.user,
                ),
                _buildLoanTypeCard(
                  context,
                  'Home Loan',
                  'Up to ₹ 5 Crores',
                  '8.4% p.a',
                  LucideIcons.home,
                ),
                _buildLoanTypeCard(
                  context,
                  'Car Loan',
                  'Up to ₹ 50 Lakhs',
                  '9.2% p.a',
                  LucideIcons.car,
                ),
                _buildLoanTypeCard(
                  context,
                  'Education Loan',
                  'Up to ₹ 75 Lakhs',
                  '11.0% p.a',
                  LucideIcons.graduationCap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        const Text(
          'Loans & Credit',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: AppTheme.glassDecoration.copyWith(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instant Credit Limit',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '₹ 5,00,000',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Get pre-approved loans within minutes based on your portfolio.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.push('/loans/apply'),
            child: const Text('Check Eligibility'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanTypeCard(
    BuildContext context,
    String title,
    String amount,
    String rate,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.glassDecoration,
      child: InkWell(
        onTap: () => context.push('/loans/apply'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
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
                    Text(
                      amount,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rate,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Text(
                    'Interest Rate',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
