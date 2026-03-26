import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class LumpsumCalculatorScreen extends StatefulWidget {
  const LumpsumCalculatorScreen({super.key});

  @override
  State<LumpsumCalculatorScreen> createState() =>
      _LumpsumCalculatorScreenState();
}

class _LumpsumCalculatorScreenState extends State<LumpsumCalculatorScreen> {
  double _investment = 100000;
  double _expectedReturn = 12;
  double _timePeriod = 10;

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
                      'Lumpsum Calculator',
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
                        'One-Time Investment',
                        '₹ ${_investment.toInt()}',
                        _investment,
                        1000,
                        10000000,
                        (val) => setState(() => _investment = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderSection(
                        'Expected Return Rate',
                        '${_expectedReturn.toInt()}% p.a',
                        _expectedReturn,
                        1,
                        30,
                        (val) => setState(() => _expectedReturn = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderSection(
                        'Time Period',
                        '${_timePeriod.toInt()} Years',
                        _timePeriod,
                        1,
                        40,
                        (val) => setState(() => _timePeriod = val),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/marketplace'),
                        icon: const Icon(LucideIcons.briefcase, size: 18),
                        label: const Text('Invest Now'),
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
    // FV = P * (1 + r/100)^n
    double futureValue =
        _investment * _pow(1 + _expectedReturn / 100, _timePeriod.toInt());
    double estimatedReturns = futureValue - _investment;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          const Text(
            'Estimated Wealth',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${futureValue.toStringAsFixed(0)}',
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
                'Invested',
                '₹ ${_investment.toStringAsFixed(0)}',
              ),
              _buildSimpleResult(
                'Returns',
                '₹ ${estimatedReturns.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
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
          activeColor: AppTheme.primaryColor,
          inactiveColor: AppTheme.surfaceColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
