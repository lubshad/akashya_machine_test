import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  double _monthlyInvestment = 5000;
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
                      'SIP Calculator',
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
                        'Monthly Investment',
                        '₹ ${_monthlyInvestment.toInt()}',
                        _monthlyInvestment,
                        500,
                        100000,
                        (val) => setState(() => _monthlyInvestment = val),
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
                        icon: const Icon(LucideIcons.trendingUp, size: 18),
                        label: const Text('Start SIP Now'),
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
    // Basic SIP formula: M = P × ({[1 + i]^n – 1} / i) × (1 + i)
    double i = (_expectedReturn / 100) / 12;
    double n = _timePeriod * 12;
    double futureValue =
        _monthlyInvestment *
        ((num.parse((1 + i).toString()).pow(n.toInt()) - 1) / i) *
        (1 + i);
    double totalInvested = _monthlyInvestment * n;
    double estimatedReturns = futureValue - totalInvested;

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
                '₹ ${totalInvested.toStringAsFixed(0)}',
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
}

extension on num {
  num pow(int exponent) {
    num result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}
