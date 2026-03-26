import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});

  static const _articles = [
    _Article(
      'Market Alert: Nifty hits all-time high',
      'Financial Times • 2h ago',
      'Market analysis of the recent surge in Indian stock markets and what it means for retail investors investing in NIFTY 50 & SENSEX.',
      'Breaking',
    ),
    _Article(
      'New Tax Guidelines for Mutual Funds',
      'MoneyControl • 5h ago',
      'Everything you need to know about the latest capital gains tax updates from the Union Budget session for FY 2024-25.',
      'Tax',
    ),
    _Article(
      'RBI keeps Repo Rate unchanged at 6.5%',
      'Business Standard • 1d ago',
      'The central bank decides to maintain status quo on interest rates, citing persistent inflation concerns in the Indian economy.',
      'Policy',
    ),
    _Article(
      'Why diversification matters in 2024',
      'Finvestea Insights • 2d ago',
      'Expert tips on how to balance your portfolio across equities, debt, and gold for better risk-adjusted returns.',
      'Strategy',
    ),
    _Article(
      'Infosys beats Q3 estimates, stock up 4%',
      'Economic Times • 3d ago',
      'IT bellwether Infosys reported a strong quarter driven by deal wins and margin improvement, sending shares higher.',
      'Stocks',
    ),
  ];

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
                      'Latest Insights',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.search,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              // Filter chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children:
                      [
                        'All',
                        'Markets',
                        'Stocks',
                        'Mutual Funds',
                        'Tax',
                        'Policy',
                      ].map((label) {
                        final isSelected = label == 'All';
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.black : Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (_) {},
                            selectedColor: AppTheme.primaryColor,
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.white12,
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _buildNewsCard(context, _articles[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, _Article article) {
    return InkWell(
      onTap: () => context.push('/academy/article'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: AppTheme.glassDecoration,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.newspaper,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      article.meta,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryAccentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.tag,
                      style: const TextStyle(
                        color: AppTheme.secondaryAccentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                article.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton(
                    onPressed: () => context.push('/academy/article'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      'Read More →',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      LucideIcons.bookmark,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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

class _Article {
  final String title, meta, summary, tag;
  const _Article(this.title, this.meta, this.summary, this.tag);
}
