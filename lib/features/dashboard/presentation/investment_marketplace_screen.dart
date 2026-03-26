import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class InvestmentMarketplaceScreen extends StatelessWidget {
  const InvestmentMarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.mainGradient,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                const SizedBox(height: 16),
                _buildSearchSection(),
                const SizedBox(height: 32),
                _buildSectionHeader('Trending Investments'),
                const SizedBox(height: 16),
                _buildTrendingGrid(context),
                const SizedBox(height: 32),
                _buildSectionHeader('New Opportunities'),
                const SizedBox(height: 16),
                _buildOpportunityCard(
                  context,
                  'Green Energy Fund',
                  'ESG focused mutual fund.',
                  '18.5%',
                  LucideIcons.leaf,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                _buildOpportunityCard(
                  context,
                  'Tech Giants Basket',
                  'Top 10 global tech stocks.',
                  '22.1%',
                  LucideIcons.monitor,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        const Text(
          'Investment Marketplace',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: AppTheme.glassDecoration,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search stocks, funds, or goals',
          prefixIcon: const Icon(
            LucideIcons.search,
            color: AppTheme.primaryColor,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTrendingGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildTrendCard(
          context,
          'High Yield',
          '15%+ returns',
          LucideIcons.trendingUp,
        ),
        _buildTrendCard(
          context,
          'Tax Savers',
          'Section 80C',
          LucideIcons.shield,
        ),
        _buildTrendCard(
          context,
          'Index Funds',
          'Passive growth',
          LucideIcons.activity,
        ),
        _buildTrendCard(context, 'Gold ETFs', 'Safe haven', LucideIcons.coins),
      ],
    );
  }

  Widget _buildTrendCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      decoration: AppTheme.glassDecoration,
      child: InkWell(
        onTap: () => context.push('/mutual-funds'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityCard(
    BuildContext context,
    String title,
    String desc,
    String returns,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: AppTheme.glassDecoration,
      child: InkWell(
        onTap: () => context.push('/fund-details'),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
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
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    returns,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const Text(
                    'Returns',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
