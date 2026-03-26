import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/theme.dart';

class CkycLookupScreen extends StatefulWidget {
  const CkycLookupScreen({super.key});

  @override
  State<CkycLookupScreen> createState() => _CkycLookupScreenState();
}

class _CkycLookupScreenState extends State<CkycLookupScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startLookup();
  }

  Future<void> _startLookup() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              'KYC Verification',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Checking your CKYC records',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 64),
            Center(
              child: _isLoading
                  ? Column(
                      children: [
                        const SpinKitDoubleBounce(
                          color: AppTheme.primaryColor,
                          size: 80.0,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Searching for your records...',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.checkCircle,
                            color: AppTheme.primaryColor,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Records Found!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We found your records in the Central KYC registry.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
            ),
            const Spacer(),
            if (!_isLoading)
              ElevatedButton(
                onPressed: () => context.push('/aadhaar-kyc'),
                child: const Text('Continue to Aadhaar KYC'),
              ),
          ],
          ),
        ),
      ),
    );
  }
}
