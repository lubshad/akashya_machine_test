import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double _loanAmount = 1000000;
  double _interestRate = 10;
  double _tenure = 5;

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
                      'EMI Calculator',
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
                        'Loan Amount',
                        '₹ ${_loanAmount.toInt()}',
                        _loanAmount,
                        10000,
                        10000000,
                        (val) => setState(() => _loanAmount = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderSection(
                        'Interest Rate',
                        '${_interestRate.toStringAsFixed(1)}% p.a',
                        _interestRate,
                        1,
                        30,
                        (val) => setState(() => _interestRate = val),
                      ),
                      const SizedBox(height: 32),
                      _buildSliderSection(
                        'Loan Tenure',
                        '${_tenure.toInt()} Years',
                        _tenure,
                        1,
                        30,
                        (val) => setState(() => _tenure = val),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/loans/apply'),
                        icon: const Icon(LucideIcons.calculator, size: 18),
                        label: const Text('Apply for Loan'),
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
    // EMI = P * r * (1+r)^n / ((1+r)^n - 1)
    double r = _interestRate / 12 / 100;
    int n = (_tenure * 12).toInt();
    double emi = 0;
    if (r > 0) {
      double factor = _pow(1 + r, n);
      emi = _loanAmount * r * factor / (factor - 1);
    } else {
      emi = _loanAmount / n;
    }
    double totalPayment = emi * n;
    double totalInterest = totalPayment - _loanAmount;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: [
          const Text(
            'Monthly EMI',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${emi.toStringAsFixed(0)}',
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
                'Principal',
                '₹ ${_loanAmount.toStringAsFixed(0)}',
              ),
              _buildSimpleResult(
                'Total Interest',
                '₹ ${totalInterest.toStringAsFixed(0)}',
              ),
              _buildSimpleResult(
                'Total Payment',
                '₹ ${totalPayment.toStringAsFixed(0)}',
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
