import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class TaxSaverCalculatorScreen extends StatefulWidget {
  const TaxSaverCalculatorScreen({super.key});

  @override
  State<TaxSaverCalculatorScreen> createState() =>
      _TaxSaverCalculatorScreenState();
}

class _TaxSaverCalculatorScreenState extends State<TaxSaverCalculatorScreen> {
  double _investment = 50000;
  int _taxBracketIndex = 1; // 0=5%, 1=20%, 2=30%

  static const List<String> _brackets = ['5%', '20%', '30%'];
  static const List<double> _rates = [0.05, 0.20, 0.30];

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
                      'Tax Saver (ELSS)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultCard(),
                      const SizedBox(height: 40),
                      _buildSliderSection(
                        'ELSS Investment',
                        '₹ ${_investment.toInt()}',
                        _investment,
                        500,
                        150000,
                        (val) => setState(() => _investment = val),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Your Tax Bracket',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(_brackets.length, (i) {
                          final selected = _taxBracketIndex == i;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _taxBracketIndex = i),
                              child: Container(
                                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppTheme.primaryColor.withValues(alpha: 0.15)
                                      : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? AppTheme.primaryColor
                                        : Colors.white10,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _brackets[i],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: selected
                                          ? AppTheme.primaryColor
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      _buildInfoCard(),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/marketplace'),
                        icon: const Icon(LucideIcons.shield, size: 18),
                        label: const Text('Invest in ELSS Now'),
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

  Widget _buildResultCard() {
    final maxDeduction = 150000.0;
    final eligibleAmount = _investment > maxDeduction ? maxDeduction : _investment;
    final taxSaved = eligibleAmount * _rates[_taxBracketIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          const Text(
            'Tax Savings under Section 80C',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${taxSaved.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSimpleResult(
                'Investment',
                '₹ ${_investment.toInt()}',
              ),
              _buildSimpleResult(
                'Deduction Limit',
                '₹ 1,50,000',
              ),
              _buildSimpleResult(
                'Lock-in',
                '3 Years',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, color: AppTheme.primaryColor, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'ELSS funds have the shortest lock-in period of 3 years among all 80C investments and historically offer higher returns through equity exposure.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleResult(String label, String value) {
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSliderSection(
    String title,
    String value,
    double current,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.surfaceColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
