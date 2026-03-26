import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class BankLinkingScreen extends StatelessWidget {
  const BankLinkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            Text(
              'Link Bank Account',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Select your bank for seamless transactions',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 48),
            Expanded(
              child: ListView(
                children: [
                  _buildBankItem(context, 'HDFC Bank', LucideIcons.building),
                  _buildBankItem(context, 'ICICI Bank', LucideIcons.building),
                  _buildBankItem(
                    context,
                    'State Bank of India',
                    LucideIcons.building,
                  ),
                  _buildBankItem(context, 'Axis Bank', LucideIcons.building),
                  _buildBankItem(
                    context,
                    'Hindustan Bank',
                    LucideIcons.building,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.search, size: 20),
                    label: const Text('Search for other banks'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.push('/account-activation'),
              child: const Text('Continue'),
            ),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankItem(BuildContext context, String name, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(
          LucideIcons.chevronRight,
          size: 18,
          color: AppTheme.textSecondary,
        ),
        onTap: () {},
      ),
    );
  }
}
