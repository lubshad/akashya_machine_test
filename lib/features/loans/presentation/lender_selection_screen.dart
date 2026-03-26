import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class LenderSelectionScreen extends StatelessWidget {
  const LenderSelectionScreen({super.key});

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
                        'Select Your Lender',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Based on your profile, we found 4 matching offers.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 32),
                      _buildLenderCard(
                        context,
                        'HDFC Bank',
                        '10.5%',
                        '₹ 16,250',
                        'No pre-payment penalty',
                        true,
                      ),
                      _buildLenderCard(
                        context,
                        'ICICI Bank',
                        '10.75%',
                        '₹ 16,420',
                        'Paperless processing',
                        false,
                      ),
                      _buildLenderCard(
                        context,
                        'SBI Finance',
                        '11.0%',
                        '₹ 16,600',
                        'Lowest processing fee',
                        false,
                      ),
                      _buildLenderCard(
                        context,
                        'Axis Bank',
                        '10.9%',
                        '₹ 16,510',
                        'Instant disbursal',
                        false,
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
            'Offers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLenderCard(
    BuildContext context,
    String bank,
    String rate,
    String emi,
    String highlight,
    bool recommended,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: AppTheme.glassDecoration.copyWith(
        border: Border.all(
          color: recommended
              ? AppTheme.primaryColor
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Stack(
        children: [
          if (recommended)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.landmark,
                        color: AppTheme.secondaryAccentColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bank,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          highlight,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('Interest', rate),
                    _buildMetric('EMI', emi),
                    _buildMetric('Duration', '36 Mo'),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: recommended
                        ? AppTheme.primaryColor
                        : Colors.white10,
                  ),
                  child: const Text('Select Offer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
