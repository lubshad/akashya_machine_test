import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'app_config.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/onboarding/presentation/login_screen.dart';
import '../features/onboarding/presentation/otp_screen.dart';
import '../features/onboarding/presentation/register_screen.dart';
import '../features/onboarding/presentation/basic_info_screen.dart';
import '../features/onboarding/presentation/pan_verification_screen.dart';
import '../features/onboarding/presentation/ckyc_lookup_screen.dart';
import '../features/onboarding/presentation/aadhaar_kyc_screen.dart';
import '../features/onboarding/presentation/address_confirmation_screen.dart';
import '../features/onboarding/presentation/bank_linking_screen.dart';
import '../features/onboarding/presentation/account_activation_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/dashboard/presentation/mutual_fund_list_screen.dart';
import '../features/dashboard/presentation/market_overview_screen.dart';
import '../features/dashboard/presentation/profile_screen.dart';
import '../features/dashboard/presentation/settings_screen.dart';
import '../features/dashboard/presentation/investment_marketplace_screen.dart';
import '../features/dashboard/presentation/portfolio_reports_screen.dart';
import '../features/dashboard/presentation/portfolio_import_screen.dart';
import '../features/dashboard/presentation/recommended_portfolio_screen.dart';
import '../features/dashboard/presentation/transaction_history_screen.dart';
import '../features/dashboard/presentation/help_center_screen.dart';
import '../features/dashboard/presentation/fund_details_screen.dart';
import '../features/dashboard/presentation/investment_order_screen.dart';
import '../features/dashboard/presentation/order_confirmation_screen.dart';
import '../features/dashboard/presentation/nominee_management_screen.dart';
import '../features/dashboard/presentation/add_nominee_screen.dart';
import '../features/dashboard/presentation/personal_info_screen.dart';
import '../features/dashboard/presentation/goal_list_screen.dart';
import '../features/dashboard/presentation/create_goal_screen.dart';
import '../features/dashboard/presentation/risk_profiling_screen.dart';
import '../features/dashboard/presentation/news_feed_screen.dart';
import '../features/dashboard/presentation/fund_performance_screen.dart';
import '../features/dashboard/presentation/payment_gateway_screen.dart';
import '../features/dashboard/presentation/services_hub_screen.dart';
import '../features/academy/presentation/article_page_screen.dart';
import '../features/calculators/presentation/calculators_home_screen.dart';
import '../features/calculators/presentation/sip_calculator_screen.dart';
import '../features/calculators/presentation/retirement_planner_screen.dart';
import '../features/calculators/presentation/lumpsum_calculator_screen.dart';
import '../features/calculators/presentation/emi_calculator_screen.dart';
import '../features/calculators/presentation/tax_saver_calculator_screen.dart';
import '../features/academy/presentation/academy_home_screen.dart';
import '../features/academy/presentation/course_list_screen.dart';
import '../features/academy/presentation/video_player_screen.dart';
import '../features/loans/presentation/loans_home_screen.dart';
import '../features/loans/presentation/loan_application_screen.dart';
import '../features/loans/presentation/lender_selection_screen.dart';
import '../features/dashboard/presentation/add_investment_screen.dart';

// Auth-guarded routes — unauthenticated users are redirected to /welcome.
const _protectedRoutes = {
  '/dashboard',
  '/mutual-funds',
  '/fund-performance',
  '/market-overview',
  '/profile',
  '/settings',
  '/marketplace',
  '/reports',
  '/portfolio-import',
  '/portfolio-insights',
  '/recommended-portfolio',
  '/transactions',
  '/help',
  '/services-hub',
  '/fund-details',
  '/mutual-funds/order',
  '/payment-gateway',
  '/mutual-funds/confirm',
  '/nominees',
  '/nominees/add',
  '/personal-info',
  '/goals',
  '/goals/create',
  '/risk-profiling',
  '/news-feed',
  '/calculators',
  '/calculators/sip',
  '/calculators/retirement',
  '/calculators/lumpsum',
  '/calculators/emi',
  '/calculators/tax-saver',
  '/academy',
  '/academy/courses',
  '/academy/video-player',
  '/academy/article',
  '/loans',
  '/loans/apply',
  '/loans/lender-selection',
  '/add-investment',
};

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: AppConfig.navigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final isAuthenticated = FirebaseAuth.instance.currentUser != null;
      final location = state.matchedLocation;

      // Always let the splash screen run its own timer-based navigation.
      if (location == '/splash') return null;

      // Authenticated user on auth screens → send to dashboard.
      final isAuthScreen = {
        '/welcome',
        '/login',
        '/register',
        '/otp',
      }.contains(location);
      if (isAuthenticated && isAuthScreen) return '/dashboard';

      // Unauthenticated user on a protected screen → send to welcome.
      if (!isAuthenticated && _protectedRoutes.contains(location)) {
        return '/welcome';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: '/otp', builder: (context, state) => const OtpScreen()),
      GoRoute(
        path: '/basic-info',
        builder: (context, state) => const BasicInfoScreen(),
      ),
      GoRoute(
        path: '/pan-verification',
        builder: (context, state) => const PanVerificationScreen(),
      ),
      GoRoute(
        path: '/ckyc-lookup',
        builder: (context, state) => const CkycLookupScreen(),
      ),
      GoRoute(
        path: '/aadhaar-kyc',
        builder: (context, state) => const AadhaarKycScreen(),
      ),
      GoRoute(
        path: '/address-confirmation',
        builder: (context, state) => const AddressConfirmationScreen(),
      ),
      GoRoute(
        path: '/bank-linking',
        builder: (context, state) => const BankLinkingScreen(),
      ),
      GoRoute(
        path: '/account-activation',
        builder: (context, state) => const AccountActivationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/mutual-funds',
        builder: (context, state) => const MutualFundListScreen(),
      ),
      GoRoute(
        path: '/fund-performance',
        builder: (context, state) => const FundPerformanceScreen(),
      ),
      GoRoute(
        path: '/market-overview',
        builder: (context, state) => const MarketOverviewScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/marketplace',
        builder: (context, state) => const InvestmentMarketplaceScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const PortfolioReportsScreen(),
      ),
      GoRoute(
        path: '/portfolio-import',
        builder: (context, state) => const PortfolioImportScreen(),
      ),
      GoRoute(
        path: '/portfolio-insights',
        builder: (context, state) => const PortfolioReportsScreen(),
      ),
      GoRoute(
        path: '/recommended-portfolio',
        builder: (context, state) => const RecommendedPortfolioScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/services-hub',
        builder: (context, state) => const ServicesHubScreen(),
      ),
      GoRoute(
        path: '/academy/article',
        builder: (context, state) => const ArticlePageScreen(),
      ),
      GoRoute(
        path: '/fund-details',
        builder: (context, state) => const FundDetailsScreen(),
      ),
      GoRoute(
        path: '/mutual-funds/order',
        builder: (context, state) => const InvestmentOrderScreen(),
      ),
      GoRoute(
        path: '/payment-gateway',
        builder: (context, state) => const PaymentGatewayScreen(),
      ),
      GoRoute(
        path: '/mutual-funds/confirm',
        builder: (context, state) => const OrderConfirmationScreen(),
      ),
      GoRoute(
        path: '/nominees',
        builder: (context, state) => const NomineeManagementScreen(),
      ),
      GoRoute(
        path: '/nominees/add',
        builder: (context, state) => const AddNomineeScreen(),
      ),
      GoRoute(
        path: '/personal-info',
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (context, state) => const GoalListScreen(),
      ),
      GoRoute(
        path: '/goals/create',
        builder: (context, state) => const CreateGoalScreen(),
      ),
      GoRoute(
        path: '/risk-profiling',
        builder: (context, state) => const RiskProfilingScreen(),
      ),
      GoRoute(
        path: '/news-feed',
        builder: (context, state) => const NewsFeedScreen(),
      ),
      GoRoute(
        path: '/calculators',
        builder: (context, state) => const CalculatorsHomeScreen(),
      ),
      GoRoute(
        path: '/calculators/sip',
        builder: (context, state) => const SipCalculatorScreen(),
      ),
      GoRoute(
        path: '/calculators/retirement',
        builder: (context, state) => const RetirementPlannerScreen(),
      ),
      GoRoute(
        path: '/calculators/lumpsum',
        builder: (context, state) => const LumpsumCalculatorScreen(),
      ),
      GoRoute(
        path: '/calculators/emi',
        builder: (context, state) => const EmiCalculatorScreen(),
      ),
      GoRoute(
        path: '/calculators/tax-saver',
        builder: (context, state) => const TaxSaverCalculatorScreen(),
      ),
      GoRoute(
        path: '/academy',
        builder: (context, state) => const AcademyHomeScreen(),
      ),
      GoRoute(
        path: '/academy/courses',
        builder: (context, state) => const CourseListScreen(),
      ),
      GoRoute(
        path: '/academy/video-player',
        builder: (context, state) => const VideoPlayerScreen(),
      ),
      GoRoute(
        path: '/loans',
        builder: (context, state) => const LoansHomeScreen(),
      ),
      GoRoute(
        path: '/loans/apply',
        builder: (context, state) => const LoanApplicationScreen(),
      ),
      GoRoute(
        path: '/loans/lender-selection',
        builder: (context, state) => const LenderSelectionScreen(),
      ),
      GoRoute(
        path: '/add-investment',
        builder: (context, state) => const AddInvestmentScreen(),
      ),
    ],
  );
}
