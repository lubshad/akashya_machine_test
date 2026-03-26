import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class GoalListScreen extends StatelessWidget {
  const GoalListScreen({super.key});

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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildGoalCard(
                        context,
                        'Dream Home',
                        '₹ 85.00 Lakhs',
                        'Target by 2030',
                        0.45,
                        LucideIcons.home,
                        Colors.blueAccent,
                      ),
                      const SizedBox(height: 24),
                      _buildGoalCard(
                        context,
                        'Child\'s Education',
                        '₹ 40.00 Lakhs',
                        'Target by 2035',
                        0.25,
                        LucideIcons.graduationCap,
                        Colors.orangeAccent,
                      ),
                      const SizedBox(height: 24),
                      _buildGoalCard(
                        context,
                        'World Tour',
                        '₹ 15.00 Lakhs',
                        'Target by 2026',
                        0.70,
                        LucideIcons.plane,
                        Colors.purpleAccent,
                      ),
                      const SizedBox(height: 32),
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
          const SizedBox(width: 8),
          const Text(
            'My Investment Goals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    String title,
    String amount,
    String target,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: AppTheme.glassDecoration,
      child: InkWell(
        onTap: () => context.push('/recommended-portfolio'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          target,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 14,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Shortfall: ₹ 12.00 Lakhs',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent),
                  ),
                  const Spacer(),
                  const Text(
                    'Analyze Goal',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: AppTheme.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: ElevatedButton.icon(
        onPressed: () => context.push('/goals/create'),
        icon: const Icon(LucideIcons.plusCircle, size: 20),
        label: const Text('Create New Goal'),
      ),
    );
  }
}
