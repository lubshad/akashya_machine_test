import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class RetirementPlannerScreen extends StatefulWidget {
  const RetirementPlannerScreen({super.key});

  @override
  State<RetirementPlannerScreen> createState() =>
      _RetirementPlannerScreenState();
}

class _RetirementPlannerScreenState extends State<RetirementPlannerScreen> {
  double _currentAge = 25;
  double _retirementAge = 60;
  double _monthlyExpenses = 50000;
  final double _expectedInflation = 6;

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
                      'Retirement Planner',
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
                        'Current Age',
                        '${_currentAge.toInt()} Years',
                        _currentAge,
                        18,
                        60,
                        (val) => setState(() => _currentAge = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderSection(
                        'Retirement Age',
                        '${_retirementAge.toInt()} Years',
                        _retirementAge,
                        40,
                        75,
                        (val) => setState(() => _retirementAge = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderSection(
                        'Monthly Expenses (Today)',
                        '₹ ${_monthlyExpenses.toInt()}',
                        _monthlyExpenses,
                        5000,
                        500000,
                        (val) => setState(() => _monthlyExpenses = val),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/calculators/sip'),
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        label: const Text('Plan SIP for Retirement'),
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
    int yearsToRetire = (_retirementAge - _currentAge).toInt();
    double inflationAdjustedExpenses =
        _monthlyExpenses * _pow(1 + (_expectedInflation / 100), yearsToRetire);
    // Simple rule of thumb: 20x annual expenses for retirement corpus
    double targetCorpus = inflationAdjustedExpenses * 12 * 20;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          const Text(
            'Target Corpus Needed',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${(targetCorpus / 10000000).toStringAsFixed(2)} Cr',
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
                'Monthly Exp at Retirement',
                '₹ ${(inflationAdjustedExpenses / 1000).toStringAsFixed(0)}k',
              ),
              _buildSimpleResult('Years to Retirement', '$yearsToRetire Years'),
            ],
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          divisions: (max - min).toInt(),
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.surfaceColor,
          onChanged: onChanged,
        ),
      ],
    );
  }

  double _pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }
}
