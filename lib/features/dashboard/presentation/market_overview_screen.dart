import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class MarketOverviewScreen extends StatelessWidget {
  const MarketOverviewScreen({super.key});

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMarketIndices(),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Top Gainers (Today)'),
                      const SizedBox(height: 16),
                      _buildStockList(context, [
                        _StockData('TCS', '₹ 3,450', '+2.4%', true),
                        _StockData('HDFC Bank', '₹ 1,620', '+1.8%', true),
                        _StockData('Reliance', '₹ 2,890', '+1.2%', true),
                      ]),
                      const SizedBox(height: 32),
                      _buildSectionHeader('Top Losers (Today)'),
                      const SizedBox(height: 16),
                      _buildStockList(context, [
                        _StockData('Infosys', '₹ 1,420', '-3.1%', false),
                        _StockData('Wipro', '₹ 410', '-2.5%', false),
                        _StockData('ICICI Bank', '₹ 940', '-0.8%', false),
                      ]),
                      const SizedBox(height: 32),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/news-feed'),
                        icon: const Icon(LucideIcons.newspaper, size: 18),
                        label: const Text('View Market News'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
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
            'Market Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketIndices() {
    return Row(
      children: [
        Expanded(
          child: _buildIndexCard('NIFTY 50', '21,450', '+120 (0.56%)', true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildIndexCard('SENSEX', '71,230', '+450 (0.64%)', true),
        ),
      ],
    );
  }

  Widget _buildIndexCard(
    String title,
    String value,
    String change,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glassDecoration.copyWith(
        color: isPositive
            ? AppTheme.primaryColor.withValues(alpha: 0.07)
            : Colors.red.withValues(alpha: 0.07),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              fontSize: 11,
              color: isPositive ? AppTheme.primaryColor : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStockList(BuildContext context, List<_StockData> stocks) {
    return Container(
      decoration: AppTheme.glassDecoration,
      child: Column(
        children: stocks.asMap().entries.map((entry) {
          final index = entry.key;
          final stock = entry.value;
          return Column(
            children: [
              _buildStockItem(context, stock),
              if (index < stocks.length - 1)
                const Divider(height: 1, indent: 16, color: Colors.white10),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockItem(BuildContext context, _StockData stock) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          LucideIcons.landmark,
          size: 18,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(
        stock.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        stock.price,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: stock.isPositive
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          stock.change,
          style: TextStyle(
            fontSize: 12,
            color: stock.isPositive ? AppTheme.primaryColor : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${stock.name} details coming soon!'),
            backgroundColor: AppTheme.surfaceColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}

class _StockData {
  final String name;
  final String price;
  final String change;
  final bool isPositive;
  _StockData(this.name, this.price, this.change, this.isPositive);
}
