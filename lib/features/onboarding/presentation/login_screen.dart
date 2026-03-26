import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';
import '../../../core/app_config.dart';
import '../../../core/helpers/toast_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

enum _AuthTab { phone, email }

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _AuthTab _tab = _AuthTab.email;

  // Phone tab
  final _phoneController = TextEditingController();

  // Email tab
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (AppConfig.isDebug) {
      _phoneController.text = AppConfig.devPhone ?? '';
      _emailController.text = AppConfig.devEmail ?? '';
      _passwordController.text = AppConfig.devPassword ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─────────────────── Handlers ───────────────────

  void _onSendOTP() {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ToastHelper.showError(
        context,
        message: 'Please enter a valid 10-digit mobile number.',
      );
      return;
    }
    context.read<AuthBloc>().add(AuthSendOTPRequested(phone));
  }

  void _onSignInWithEmail() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      ToastHelper.showError(
        context,
        message: 'Please enter a valid email address.',
      );
      return;
    }
    if (password.isEmpty) {
      ToastHelper.showError(context, message: 'Please enter your password.');
      return;
    }

    context.read<AuthBloc>().add(AuthLoginEmailRequested(email, password));
  }

  void _onForgotPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ToastHelper.showError(
        context,
        message: 'Enter your email above first, then tap Forgot Password.',
      );
      return;
    }
    context.read<AuthBloc>().add(AuthResetPasswordRequested(email));
  }

  // ─────────────────── Build ───────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOTPSent) {
          context.push(
            '/otp',
            extra: {
              'verificationId': state.verificationId,
              'phoneNumber': state.phoneNumber,
            },
          );
        } else if (state is AuthResetPasswordEmailSent) {
          ToastHelper.showSuccess(
            context,
            message: 'Password reset link sent to ${state.email}',
          );
        } else if (state is AuthUnauthenticated && state.error != null) {
          ToastHelper.showError(context, message: state.error!);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errorMessage = (state is AuthUnauthenticated)
            ? state.error
            : null;

        return Scaffold(
          body: Container(
            decoration: AppTheme.mainGradient,
            child: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue to Finvestea',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 32),
                          _buildTabSwitcher(),
                          const SizedBox(height: 28),
                          if (_tab == _AuthTab.phone) _buildPhoneFields(),
                          if (_tab == _AuthTab.email) _buildEmailFields(),
                          const SizedBox(height: 20),
                          if (errorMessage != null)
                            _buildErrorBanner(errorMessage),
                          const SizedBox(height: 16),
                          if (_tab == _AuthTab.email)
                            Center(
                              child: TextButton(
                                onPressed: isLoading ? null : _onForgotPassword,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            'By continuing, you agree to our Terms of Service and Privacy Policy.',
                            style: TextStyle(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.5,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: TextButton(
                              onPressed: () => context.push('/register'),
                              child: RichText(
                                text: TextSpan(
                                  text: "Don't have an account? ",
                                  style: TextStyle(
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 14,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: 'Create Account',
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(isLoading),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabItem(_AuthTab.email, LucideIcons.mail, 'Email'),
          _buildTabItem(_AuthTab.phone, LucideIcons.smartphone, 'Mobile OTP'),
        ],
      ),
    );
  }

  Widget _buildTabItem(_AuthTab tab, IconData icon, String label) {
    final isActive = _tab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _tab = tab;
          context.read<AuthBloc>().add(AuthErrorResetRequested());
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mobile Number',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: AppTheme.glassDecoration,
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
            decoration: InputDecoration(
              hintText: '10-digit mobile number',
              prefixIcon: const Icon(
                LucideIcons.phone,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              prefixText: '+91  ',
              prefixStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: AppTheme.glassDecoration,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'you@example.com',
              prefixIcon: Icon(
                LucideIcons.mail,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Password',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: AppTheme.glassDecoration,
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(
                LucideIcons.lock,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: Colors.redAccent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isLoading) {
    final isPhone = _tab == _AuthTab.phone;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : (isPhone ? _onSendOTP : _onSignInWithEmail),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(isPhone ? 'Send OTP' : 'Log In'),
      ),
    );
  }
}
