import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    LucideIcons.checkCircle,
                    color: AppTheme.primaryColor,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Investment Successful!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your SIP for Bluechip Growth Fund has been successfully set up.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 48),
                _buildOrderDetails(),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Back to Home'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push('/transactions'),
                  child: const Text(
                    'View Transaction History',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          _buildRow('Amount Paid', '₹ 5,000.00'),
          const Divider(height: 32, color: Colors.white10),
          _buildRow('Fund Name', 'Bluechip Growth Fund'),
          const Divider(height: 32, color: Colors.white10),
          _buildRow('Order ID', '#INV-882910'),
          const Divider(height: 32, color: Colors.white10),
          _buildRow('SIP Date', '5th of every month'),
          const Divider(height: 32, color: Colors.white10),
          _buildRow('Next Payment', '05 Apr 2024'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
