import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget child;
  const MainNavigationScreen({super.key, required this.child});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Determine if we should show sidebar or bottom nav
    final bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isWide ? null : _buildSidebar(context),
      appBar: _buildTopBar(context, isWide),
      body: Row(
        children: [
          if (isWide) _buildSidebar(context, isPermanent: true),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNav(context),
    );
  }

  PreferredSizeWidget _buildTopBar(BuildContext context, bool isWide) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: isWide 
        ? null 
        : IconButton(
            icon: const Icon(LucideIcons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
      title: Text(
        _getTitle(context),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: AppTheme.primaryColor),
          onPressed: () => context.push('/notifications'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context, {bool isPermanent = false}) {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: AppTheme.mainGradient,
            child: Center(
              child: Text(
                'FINVESTEA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          _buildSidebarItem(context, LucideIcons.layoutGrid, 'Dashboard', '/dashboard'),
          _buildSidebarItem(context, LucideIcons.pieChart, 'Portfolio', '/reports'),
          _buildSidebarItem(context, LucideIcons.trendingUp, 'Market', '/market-overview'),
          _buildSidebarItem(context, LucideIcons.calculator, 'Calculators', '/calculators'),
          _buildSidebarItem(context, LucideIcons.graduationCap, 'Academy', '/academy'),
          const Spacer(),
          _buildSidebarItem(context, LucideIcons.settings, 'Settings', '/settings'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, IconData icon, String label, String route) {
    final bool isActive = GoRouterState.of(context).matchedLocation.startsWith(route);
    return ListTile(
      leading: Icon(icon, color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.textSecondary,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      onTap: () {
        context.go(route);
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;
    if (location.startsWith('/dashboard')) {
      currentIndex = 0;
    } else if (location.startsWith('/reports')) {
      currentIndex = 1;
    } else if (location.startsWith('/market-overview')) {
      currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      currentIndex = 3;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0: context.go('/dashboard'); break;
            case 1: context.go('/reports'); break;
            case 2: context.go('/market-overview'); break;
            case 3: context.go('/profile'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.pieChart), label: 'Portfolio'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.layoutGrid), label: 'Market'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }

  String _getTitle(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 'Dashboard';
    if (location.startsWith('/reports')) return 'Portfolio Reports';
    if (location.startsWith('/market-overview')) return 'Market';
    if (location.startsWith('/profile')) return 'Profile';
    return 'Finvestea';
  }
}
