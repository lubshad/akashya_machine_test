import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme.dart';
import '../../../core/services/portfolio_service.dart';
import '../services/portfolio_document_parser.dart';
import '../services/portfolio_analysis_service.dart';
import '../services/portfolio_ai_insight_service.dart';

class PortfolioReportsScreen extends StatefulWidget {
  const PortfolioReportsScreen({super.key});

  @override
  State<PortfolioReportsScreen> createState() => _PortfolioReportsScreenState();
}

class _PortfolioReportsScreenState extends State<PortfolioReportsScreen>
    with SingleTickerProviderStateMixin {
  final PortfolioService _portfolioService = PortfolioService();
  StreamSubscription? _portfolioSub;
  final ScrollController _scrollController = ScrollController();
  int _activeTab = 0;
  bool _isLoading = true;
  bool _showPortfolioHeader = true;

  // One key per section: 0=Overview, 1=Returns, 2=Holdings, 3=Allocation, 4=AI Insights
  final List<GlobalKey> _sectionKeys = List.generate(5, (_) => GlobalKey());

  static const List<String> _tabLabels = [
    'Overview',
    'Returns',
    'Holdings',
    'Allocation',
    'AI Insight ✨',
  ];

  late List<PortfolioInvestment> _investments;
  late PortfolioAnalysis _analysis;
  AiInsightResult? _aiInsights;
  bool _aiLoading = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize with empty data; will be filled by the stream
    _investments = [];
    _analysis = PortfolioAnalysisService.analyze(_investments);

    _portfolioSub = _portfolioService.portfolioStream().listen((entries) {
      if (mounted) {
        setState(() {
          _investments = entries.map((e) => e.investment).toList();
          _analysis = PortfolioAnalysisService.analyze(_investments);
          _isLoading = false;
        });
      }
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _scrollController.addListener(_onScroll);
    // _scrollController.addListener(_handlePortfolioHeaderVisibility);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _screenWidth = MediaQuery.of(context).size.width;
    });
  }

  double _screenWidth = 0;

  // ── Scroll detection: update active tab based on which section is near top ──
  void _onScroll() {
    // Walk sections bottom-to-top; the last one whose top is at or above the
    // threshold wins (threshold = 200px from screen top).

    // if the direction is down and in overview

    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.forward &&
        _activeTab == 0 &&
        _scrollController.position.pixels < 100) {
      setState(() => _showPortfolioHeader = true);
    } else if (direction == ScrollDirection.reverse && _activeTab == 0) {
      setState(() => _showPortfolioHeader = false);
    }

    final double threshold = _screenWidth * (_showPortfolioHeader ? 1.5 : 0.5);
    for (int i = _sectionKeys.length - 1; i >= 0; i--) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      if (dy <= threshold) {
        if (_activeTab != i) setState(() => _activeTab = i);
        if (_activeTab != 0) {
          setState(() => _showPortfolioHeader = false);
        }
        return;
      }
    }
    // If nothing reached the threshold yet, we're at the top
    // if (_activeTab != 0) setState(() => _activeTab = 0);
  }

  // ── Smooth scroll to a section when a tab is tapped ──
  // Uses RenderAbstractViewport to compute the exact scroll offset so that
  // navigation works in both directions (up and down).
  void _scrollToSection(int index) {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;

    // RenderAbstractViewport gives us the scroll offset needed to align the
    // target to the top of the viewport (alignment = 0.0), regardless of
    // whether we are scrolling up or down.
    final viewport = RenderAbstractViewport.of(box);
    final targetOffset = viewport
        .getOffsetToReveal(box, 0.0)
        .offset
        .clamp(
          _scrollController.position.minScrollExtent,
          _scrollController.position.maxScrollExtent,
        );

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    if (index != 0) {
      setState(() => _showPortfolioHeader = false);
    }
  }

  Future<void> _loadAiInsights() async {
    setState(() => _aiLoading = true);
    final result = await PortfolioAiInsightService.generateInsights(
      _investments,
      _analysis,
    );
    if (mounted) {
      setState(() {
        _aiInsights = result;
        _aiLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _portfolioSub?.cancel();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ═══════════════════════════ BUILD ═══════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: AppTheme.mainGradient),
          Positioned(
            top: -120,
            right: -72,
            child: _buildGlowOrb(
              size: 280,
              color: AppTheme.primaryColor.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 220,
            left: -100,
            child: _buildGlowOrb(
              size: 220,
              color: AppTheme.accentCyan.withValues(alpha: 0.08),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildAppBar(context),
                  if (_isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    )
                  else if (_investments.isEmpty)
                    Expanded(child: _buildEmptyState(context))
                  else ...[
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1,
                            child: child,
                          ),
                        );
                      },
                      child: _showPortfolioHeader
                          ? _buildPortfolioHeader()
                          : const SizedBox.shrink(
                              key: ValueKey('portfolio_header_hidden'),
                            ),
                    ),
                    _buildTabBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                        child: Column(
                          children: [
                            _buildSection(0, _buildOverviewContent()),
                            _buildSection(1, _buildReturnsContent()),
                            _buildSection(2, _buildHoldingsContent()),
                            _buildSection(3, _buildAllocationContent()),
                            _buildSection(4, _buildAiInsightsContent()),
                            _buildDocumentsBlock(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/portfolio-import'),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(
          LucideIcons.uploadCloud,
          size: 18,
          color: Colors.white,
        ),
        label: const Text(
          'Import',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ═══════════════════════════ APP BAR ═══════════════════════════

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          _buildTopAction(
            icon: LucideIcons.chevronLeft,
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio & Reports',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Track returns, allocation, and AI-driven portfolio insights',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildTopAction(
            icon: LucideIcons.upload,
            onPressed: () => context.push('/portfolio-import'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════ PORTFOLIO HEADER ═══════════════════════════

  Widget _buildPortfolioHeader() {
    final fmt = PortfolioAnalysisService.formatIndianCurrency;
    return Container(
      key: const ValueKey('portfolio_header_visible'),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.premiumGlassDecoration.copyWith(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.94),
            AppTheme.highlightColor.withValues(alpha: 0.86),
            AppTheme.backgroundColorEnd.withValues(alpha: 0.94),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.wallet, size: 14, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Live Portfolio Snapshot',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_analysis.totalHoldings} holdings',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Total Portfolio Value',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmt(_analysis.currentValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _analysis.isProfit
                ? 'Your portfolio is ahead by ${_analysis.returnPercentage.toStringAsFixed(1)}% overall.'
                : 'Your portfolio is currently down ${_analysis.returnPercentage.abs().toStringAsFixed(1)}% overall.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final children = [
                _buildHeaderStat(
                  'Net Returns',
                  '${_analysis.isProfit ? '+' : ''}${fmt(_analysis.totalReturns)}',
                  _analysis.isProfit ? Colors.white : const Color(0xFFFFD3D3),
                ),
                _buildHeaderStat(
                  'Return %',
                  '${_analysis.isProfit ? '+' : ''}${_analysis.returnPercentage.toStringAsFixed(1)}%',
                  _analysis.isProfit ? Colors.white : const Color(0xFFFFD3D3),
                ),
                _buildHeaderStat(
                  'Invested',
                  fmt(_analysis.totalInvested),
                  Colors.white70,
                ),
              ];

              // if (constraints.maxWidth < 560) {
              //   return Column(
              //     children: [
              //       children[0],
              //       const SizedBox(height: 10),
              //       children[1],
              //       const SizedBox(height: 10),
              //       children[2],
              //     ],
              //   );
              // }

              return Row(
                children: [
                  Expanded(child: children[0]),
                  _buildHeaderDivider(),
                  Expanded(child: children[1]),
                  _buildHeaderDivider(),
                  Expanded(child: children[2]),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildHeaderStat(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          AutoSizeText(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            maxLines: 1,
            minFontSize: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  // ═══════════════════════════ TAB BAR (ANCHOR NAVIGATION) ══════════════════

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      decoration: AppTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(6),
        child: Row(
          children: List.generate(_tabLabels.length, (i) {
            final isActive = _activeTab == i;
            return GestureDetector(
              onTap: () => _scrollToSection(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryAccentColor,
                          ],
                        )
                      : null,
                  color: isActive ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _tabLabels[i],
                  style: TextStyle(
                    fontSize: 11,

                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ═══════════════════════════ SECTION WRAPPER ═══════════════════════════

  /// Wraps content in a keyed container with a section label.
  Widget _buildSection(int index, Widget content) {
    return Container(
          key: _sectionKeys[index],
          margin: const EdgeInsets.only(bottom: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionLabel(_tabLabels[index].replaceAll(' ✨', '')),
              const SizedBox(height: 12),
              content,
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: 80 * index))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.06, end: 0);
  }

  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 11,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════ SECTION CONTENT ═══════════════════════════

  // ── Overview ──────────────────────────────────────────────────────────────
  Widget _buildOverviewContent() {
    return Column(
      children: [
        _buildResponsiveRow([
          _buildStatCard(
            'Holdings',
            '${_analysis.totalHoldings}',
            LucideIcons.briefcase,
            AppTheme.primaryColor,
          ),
          _buildStatCard(
            'Classes',
            '${_analysis.allocation.length}',
            LucideIcons.layers,
            AppTheme.secondaryAccentColor,
          ),
        ]),
        const SizedBox(height: 12),
        _buildResponsiveRow([
          _buildStatCard(
            'CAGR',
            '${_analysis.cagr.toStringAsFixed(2)}%',
            LucideIcons.calendar,
            _analysis.cagr >= 0 ? AppTheme.primaryColor : Colors.redAccent,
          ),
          _buildStatCard(
            'Performance',
            _performanceLabel(_analysis.returnPercentage),
            LucideIcons.trendingUp,
            _analysis.isProfit ? AppTheme.primaryColor : Colors.redAccent,
          ),
        ]),
        const SizedBox(height: 20),
        _buildSubLabel('Top Sectors'),
        const SizedBox(height: 12),
        _buildPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              _buildTopSectorHeader(),
              const SizedBox(height: 18),
              ..._analysis.topSectors.map(
                (e) => _buildSectorRow(e.key, e.value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSubLabel('Top Performers'),
        const SizedBox(height: 10),
        ..._analysis.topPerformers.map(_buildInvestmentCard),
      ],
    );
  }

  Widget _buildTopSectorHeader() {
    final topSector = _analysis.topSectors.isNotEmpty
        ? _analysis.topSectors.first
        : null;
    final share = topSector == null || _analysis.currentValue == 0
        ? 0.0
        : (topSector.value / _analysis.currentValue) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.14),
            AppTheme.secondaryAccentColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              LucideIcons.pieChart,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sector Concentration',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  topSector == null
                      ? 'No sector data available yet.'
                      : '${topSector.key} leads your allocation at ${share.toStringAsFixed(1)}% of portfolio value.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorRow(String name, double value) {
    final fmt = PortfolioAnalysisService.formatCurrencyCompact;
    final share = _analysis.currentValue == 0
        ? 0.0
        : (value / _analysis.currentValue) * 100;
    final sectorColor = _typeColor(name);
    final sectorStatus = share >= 30
        ? 'High concentration'
        : share >= 15
        ? 'Balanced exposure'
        : 'Diversified allocation';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: sectorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_sectorIcon(name), color: sectorColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        fmt(value),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: sectorColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${share.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: sectorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (share / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          sectorColor,
                          sectorColor.withValues(alpha: 0.55),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: sectorColor.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              sectorStatus,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Returns ───────────────────────────────────────────────────────────────
  Widget _buildReturnsContent() {
    final strongestPerformer = _investments.reduce((a, b) {
      return a.returns >= b.returns ? a : b;
    });
    final weakestPerformer = _investments.reduce((a, b) {
      return a.returns <= b.returns ? a : b;
    });
    final positiveCount = _investments.where((investment) {
      return investment.isProfit;
    }).length;
    final negativeCount = _investments.length - positiveCount;

    return Column(
      children: [
        _buildSubLabel('Return Contribution'),
        const SizedBox(height: 20),
        _buildPanel(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildReturnInsightChip(
                      'Winning Holdings',
                      '$positiveCount',
                      LucideIcons.trendingUp,
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildReturnInsightChip(
                      'Lagging Holdings',
                      '$negativeCount',
                      LucideIcons.trendingDown,
                      Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white.withValues(alpha: 0.04),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildReturnHighlight(
                        'Top Contributor',
                        strongestPerformer.name,
                        PortfolioAnalysisService.formatCurrencyCompact(
                          strongestPerformer.returns,
                        ),
                        AppTheme.primaryColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 42,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    Expanded(
                      child: _buildReturnHighlight(
                        'Biggest Drag',
                        weakestPerformer.name,
                        PortfolioAnalysisService.formatCurrencyCompact(
                          weakestPerformer.returns,
                        ),
                        Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chartWidth = max(
                    constraints.maxWidth,
                    _investments.length * 72,
                  ).toDouble();
                  final chartExtent =
                      _investments.map((e) => e.returns.abs()).reduce(max) *
                      1.2;

                  return ScrollConfiguration(
                    behavior: const MaterialScrollBehavior().copyWith(
                      scrollbars: false,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: chartWidth,
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: chartExtent,
                            minY: -chartExtent,
                            baselineY: 0,
                            barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) => AppTheme.primaryColor
                                    .withValues(alpha: 0.9),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  final inv = _investments[groupIndex];
                                  return BarTooltipItem(
                                    '${inv.name}\n${PortfolioAnalysisService.formatCurrencyCompact(inv.returns)}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= _investments.length) {
                                      return const SizedBox();
                                    }
                                    final inv = _investments[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        inv.name.length > 6
                                            ? '${inv.name.substring(0, 5)}..'
                                            : inv.name,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 46,
                                  getTitlesWidget: (value, meta) => Text(
                                    PortfolioAnalysisService.formatCurrencyCompact(
                                      value,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: value == 0
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.06),
                                strokeWidth: value == 0 ? 1.2 : 1,
                              ),
                            ),
                            barGroups: _investments.asMap().entries.map((e) {
                              final inv = e.value;
                              final barColor = inv.isProfit
                                  ? AppTheme.primaryColor
                                  : Colors.redAccent;

                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: inv.returns,
                                    width: 18,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                      bottomRight: Radius.circular(6),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        barColor,
                                        barColor.withValues(alpha: 0.55),
                                      ],
                                    ),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: chartExtent,
                                      color: Colors.white.withValues(
                                        alpha: 0.03,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSubLabel('Holdings Profit/Loss'),
        const SizedBox(height: 10),
        _buildPanel(
          padding: const EdgeInsets.all(16),
          child: Column(children: _investments.map(_buildReturnRow).toList()),
        ),
      ],
    );
  }

  // ── Holdings ──────────────────────────────────────────────────────────────
  Widget _buildHoldingsContent() {
    return Column(
      children: _investments.map(_buildDetailedInvestmentCard).toList(),
    );
  }

  // ── Allocation ────────────────────────────────────────────────────────────
  Widget _buildAllocationContent() {
    return Column(
      children: [
        _buildSubLabel('Portfolio Diversification'),
        const SizedBox(height: 12),
        _buildPanel(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final chart = SizedBox(
                height: 190,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 40,
                    sections: _analysis.allocation.map((item) {
                      final color = Color(
                        int.parse(item.color.replaceAll('#', '0xFF')),
                      );
                      return PieChartSectionData(
                        color: color,
                        value: item.percentage,
                        title: '${item.percentage.toStringAsFixed(0)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );

              final legend = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _analysis.allocation.take(4).map((item) {
                  final color = Color(
                    int.parse(item.color.replaceAll('#', '0xFF')),
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.category,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${item.percentage.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );

              if (constraints.maxWidth < 520) {
                return Column(
                  children: [chart, const SizedBox(height: 20), legend],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 4, child: chart),
                  const SizedBox(width: 20),
                  Expanded(flex: 5, child: legend),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: _analysis.allocation.map(_buildAllocationItem).toList(),
          ),
        ),
      ],
    );
  }

  // ── AI Insights ───────────────────────────────────────────────────────────
  Widget _buildAiInsightsContent() {
    if (_aiLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_aiInsights == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: AppTheme.glassDecoration.copyWith(
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.sparkles,
              size: 36,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 12),
            const Text(
              'AI Portfolio Analysis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap below to generate AI-powered insights about your portfolio performance.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAiInsights,
              icon: const Icon(LucideIcons.sparkles, size: 16),
              label: const Text('Generate AI Insights'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        _buildAiCard(
          'Summary',
          _aiInsights!.performanceSummary,
          LucideIcons.trendingUp,
          AppTheme.primaryColor,
        ),
        _buildAiCard(
          'Risk',
          _aiInsights!.riskSummary,
          LucideIcons.shieldCheck,
          const Color(0xFF60A5FA),
        ),
        _buildAiCard(
          'Diversification',
          _aiInsights!.diversificationAnalysis,
          LucideIcons.pieChart,
          AppTheme.secondaryAccentColor,
        ),
        _buildSubLabel('Recommendations'),
        const SizedBox(height: 10),
        ..._aiInsights!.suggestions.map(_buildSuggestionCard),
      ],
    );
  }

  // ── Documents (non-anchored, always at bottom) ────────────────────────────
  Widget _buildDocumentsBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Documents'),
        const SizedBox(height: 12),
        _buildPanel(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  LucideIcons.fileSpreadsheet,
                  color: AppTheme.accentGold,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Vault',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Access statements, performance snapshots, and portfolio history in one place.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildReportCategory('Tax Statements', [
          _ReportItem(
            'Capital Gains Report',
            'FY 2023-24',
            LucideIcons.fileText,
          ),
          _ReportItem('Tax P&L Statement', 'FY 2023-24', LucideIcons.fileText),
        ]),
        const SizedBox(height: 16),
        _buildReportCategory('Performance Reports', [
          _ReportItem(
            'Monthly Portfolio Review',
            'Feb 2024',
            LucideIcons.pieChart,
          ),
          _ReportItem('Annual Performance', '2023', LucideIcons.trendingUp),
        ]),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => context.push('/transactions'),
          icon: const Icon(LucideIcons.clock, size: 18),
          label: const Text('View Transaction History'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primaryColor),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════ SHARED WIDGET HELPERS ═══════════════════════════

  Widget _buildSubLabel(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
        fontSize: 10,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return _buildPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentCard(PortfolioInvestment inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: _buildPanel(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _typeColor(inv.type).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _typeIcon(inv.type),
                color: _typeColor(inv.type),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                inv.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (inv.isProfit ? AppTheme.primaryColor : Colors.redAccent)
                    .withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${inv.isProfit ? '+' : ''}${inv.returnPercentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: inv.isProfit
                      ? AppTheme.primaryColor
                      : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInvestmentCard(PortfolioInvestment inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _typeColor(inv.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _typeIcon(inv.type),
                    color: _typeColor(inv.type),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        inv.type,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (inv.isProfit
                                ? AppTheme.primaryColor
                                : Colors.redAccent)
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${inv.isProfit ? '+' : ''}${inv.returnPercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: inv.isProfit
                          ? AppTheme.primaryColor
                          : Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInvStat(
                  'Invested',
                  PortfolioAnalysisService.formatCurrencyCompact(
                    inv.amountInvested,
                  ),
                ),
                _buildInvStat(
                  'Current',
                  PortfolioAnalysisService.formatCurrencyCompact(
                    inv.currentValue,
                  ),
                ),
                _buildInvStat(
                  'Returns',
                  PortfolioAnalysisService.formatCurrencyCompact(inv.returns),
                  color: inv.isProfit
                      ? AppTheme.primaryColor
                      : Colors.redAccent,
                ),
                _buildInvStat('Units', inv.units.toStringAsFixed(0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvStat(
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildReturnInsightChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnHighlight(
    String label,
    String name,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCard(String title, String body, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(String s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.secondaryAccentColor.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        s,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildAllocationItem(AllocationItem item) {
    final color = Color(int.parse(item.color.replaceAll('#', '0xFF')));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(item.category, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(
            PortfolioAnalysisService.formatCurrencyCompact(item.amount),
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Text(
            '${item.percentage.toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnRow(PortfolioInvestment inv) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(_typeIcon(inv.type), color: _typeColor(inv.type), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              inv.name,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            PortfolioAnalysisService.formatCurrencyCompact(inv.returns),
            style: TextStyle(
              color: inv.isProfit ? AppTheme.primaryColor : Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: _buildPanel(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.18),
                      AppTheme.secondaryAccentColor.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.barChart2,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Portfolio Data',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Import your portfolio documents to unlock performance tracking, allocation breakdowns, and AI insights.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.push('/portfolio-import'),
                icon: const Icon(LucideIcons.uploadCloud),
                label: const Text('Import Now'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCategory(String title, List<_ReportItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        _buildPanel(
          child: Column(
            children: items
                .map(
                  (item) => ListTile(
                    leading: Icon(
                      item.icon,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: const Icon(
                      LucideIcons.download,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                    onTap: () {},
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel({
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double? height,
  }) {
    return Container(
      height: height,
      padding: padding,
      decoration: AppTheme.glassDecoration,
      child: child,
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // if (constraints.maxWidth < 560) {
        //   return Column(
        //     children: [children[0], const SizedBox(height: 12), children[1]],
        //   );
        // }

        return Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 12),
            Expanded(child: children[1]),
          ],
        );
      },
    );
  }

  Widget _buildTopAction({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: AppTheme.glassDecoration.copyWith(
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: icon == LucideIcons.upload
              ? AppTheme.primaryColor
              : Colors.white,
        ),
      ),
    );
  }

  Widget _buildGlowOrb({required double size, required Color color}) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }

  // ═══════════════════════════ HELPER METHODS ═══════════════════════════

  String _performanceLabel(double pct) {
    if (pct >= 20) return 'Excellent (${pct.toStringAsFixed(1)}%)';
    if (pct >= 10) return 'Good (${pct.toStringAsFixed(1)}%)';
    if (pct >= 0) return 'Moderate (${pct.toStringAsFixed(1)}%)';
    return 'Loss (${pct.toStringAsFixed(1)}%)';
  }

  Color _typeColor(String t) {
    if (t == 'Mutual Fund') return AppTheme.primaryColor;
    if (t == 'Stock' || t == 'Stocks') return AppTheme.secondaryAccentColor;
    if (t == 'ETF') return Colors.blueAccent;
    if (t == 'Gold') return const Color(0xFFF59E0B);
    return Colors.purpleAccent;
  }

  IconData _sectorIcon(String sector) {
    final normalized = sector.toLowerCase();
    if (normalized.contains('tech')) return LucideIcons.cpu;
    if (normalized.contains('bank') || normalized.contains('finance')) {
      return LucideIcons.landmark;
    }
    if (normalized.contains('health') || normalized.contains('pharma')) {
      return LucideIcons.heartPulse;
    }
    if (normalized.contains('energy') || normalized.contains('oil')) {
      return LucideIcons.zap;
    }
    if (normalized.contains('consumer') || normalized.contains('retail')) {
      return LucideIcons.shoppingBag;
    }
    if (normalized.contains('auto')) return LucideIcons.car;
    if (normalized.contains('infra') || normalized.contains('real estate')) {
      return LucideIcons.building2;
    }
    if (normalized.contains('metal') || normalized.contains('material')) {
      return LucideIcons.factory;
    }
    return LucideIcons.pieChart;
  }

  IconData _typeIcon(String t) {
    if (t == 'Mutual Fund') return LucideIcons.barChart2;
    if (t == 'ETF') return LucideIcons.barChart;
    if (t == 'Gold') return LucideIcons.coins;
    return LucideIcons.trendingUp;
  }
}

// ═══════════════════════════ DATA CLASS ═══════════════════════════

class _ReportItem {
  final String title, subtitle;
  final IconData icon;
  _ReportItem(this.title, this.subtitle, this.icon);
}
