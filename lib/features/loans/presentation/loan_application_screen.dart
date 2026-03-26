import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class LoanApplicationScreen extends StatelessWidget {
  const LoanApplicationScreen({super.key});

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
                        'Apply for Personal Loan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Complete your application in 3 simple steps.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      _buildStepIndicator(),
                      const SizedBox(height: 32),
                      _buildInputField(
                        'Loan Amount Required',
                        '₹ 5,00,000',
                        LucideIcons.indianRupee,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        'Loan Tenure (Months)',
                        '36 Months',
                        LucideIcons.calendar,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        'Purpose of Loan',
                        'Home Renovation',
                        LucideIcons.info,
                      ),
                      const SizedBox(height: 32),
                      _buildSummaryCard(),
                    ],
                  ),
                ),
              ),
              _buildFooter(context),
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
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, 'Amount', true),
        _buildDivider(),
        _buildStep(2, 'Lender', false),
        _buildDivider(),
        _buildStep(3, 'Verify', false),
      ],
    );
  }

  Widget _buildStep(int number, String label, bool active) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: active
                ? AppTheme.primaryColor
                : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: active ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Expanded(
      child: Container(
        height: 1,
        color: Colors.white.withValues(alpha: 0.1),
        margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
      ),
    );
  }

  Widget _buildInputField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: AppTheme.glassDecoration,
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 16),
              Text(value, style: const TextStyle(fontSize: 16)),
              const Spacer(),
              const Icon(
                LucideIcons.chevronDown,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Estimated Monthly EMI', '₹ 16,250'),
          const Divider(height: 24, color: Colors.white10),
          _buildSummaryRow('Processing Fee', '₹ 2,500'),
          const Divider(height: 24, color: Colors.white10),
          _buildSummaryRow('Total Interest Payable', '₹ 85,000'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: ElevatedButton(
        onPressed: () => context.push('/loans/lender-selection'),
        child: const Text('View Available Lenders'),
      ),
    );
  }
}
