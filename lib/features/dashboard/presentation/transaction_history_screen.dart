import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              _buildFilterChips(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    _buildDateSeparator('Today, 05 Mar 2024'),
                    _buildTransactionItem(
                      context,
                      'SIP - Bluechip Growth Fund',
                      '- ₹ 5,000',
                      'Successful',
                      LucideIcons.arrowUpRight,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDateSeparator('Yesterday, 04 Mar 2024'),
                    _buildTransactionItem(
                      context,
                      'Redemption - Midcap Fund',
                      '+ ₹ 12,450',
                      'Processing',
                      LucideIcons.arrowDownLeft,
                      AppTheme.secondaryAccentColor,
                    ),
                    _buildTransactionItem(
                      context,
                      'Bank Deposit',
                      '+ ₹ 10,000',
                      'Successful',
                      LucideIcons.plus,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDateSeparator('28 Feb 2024'),
                    _buildTransactionItem(
                      context,
                      'Lump Sum - HDFC Debt Fund',
                      '- ₹ 1,00,000',
                      'Successful',
                      LucideIcons.arrowUpRight,
                      AppTheme.primaryColor,
                    ),
                    _buildTransactionItem(
                      context,
                      'SIP - Axis Midcap Fund',
                      '- ₹ 2,500',
                      'Successful',
                      LucideIcons.arrowUpRight,
                      AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 24),
                    _buildDateSeparator('20 Feb 2024'),
                    _buildTransactionItem(
                      context,
                      'Lump Sum - NIFTY 50 Index Fund',
                      '- ₹ 25,000',
                      'Successful',
                      LucideIcons.arrowUpRight,
                      AppTheme.primaryColor,
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
            'Transaction History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          _buildChip('All', true),
          _buildChip('Investments', false),
          _buildChip('Withdrawals', false),
          _buildChip('SIP', false),
          _buildChip('Failed', false),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryColor
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDateSeparator(String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        date,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    String title,
    String amount,
    String status,
    IconData icon,
    Color iconColor,
  ) {
    final bool isSuccessful = status == 'Successful';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSuccessful
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : AppTheme.secondaryAccentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isSuccessful
                              ? AppTheme.primaryColor
                              : AppTheme.secondaryAccentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: amount.startsWith('+')
                  ? AppTheme.primaryColor
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
