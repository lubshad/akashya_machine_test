import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class RiskProfilingScreen extends StatefulWidget {
  const RiskProfilingScreen({super.key});

  @override
  State<RiskProfilingScreen> createState() => _RiskProfilingScreenState();
}

class _RiskProfilingScreenState extends State<RiskProfilingScreen> {
  int _currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Risk Assessment ($_currentStep/5)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: AppTheme.mainGradient,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const LinearProgressIndicator(
              value: 0.2,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 48),
            const Text(
              'What would you do if your investment value fell by 20% in a month?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),
            _buildOptionCard('Sell all my investments immediately'),
            const SizedBox(height: 16),
            _buildOptionCard('Wait and see for a few more months'),
            const SizedBox(height: 16),
            _buildOptionCard('Invest more at lower prices', isSelected: true),
            const SizedBox(height: 16),
            _buildOptionCard('Do nothing and stay invested'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_currentStep < 5) {
                  setState(() => _currentStep++);
                } else {
                  context.push('/recommended-portfolio');
                }
              },
              child: Text(_currentStep < 5 ? 'Next Question' : 'View Results'),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(String text, {bool isSelected = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppTheme.primaryColor : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
