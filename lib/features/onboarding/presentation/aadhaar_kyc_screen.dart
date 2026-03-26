import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme.dart';

class AadhaarKycScreen extends StatefulWidget {
  const AadhaarKycScreen({super.key});

  @override
  State<AadhaarKycScreen> createState() => _AadhaarKycScreenState();
}

class _AadhaarKycScreenState extends State<AadhaarKycScreen> {
  final _aadhaarController = TextEditingController();

  @override
  void dispose() {
    _aadhaarController.dispose();
    super.dispose();
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
              'Aadhaar KYC',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Securely verify your identity using Digilocker',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 48),
            const Text(
              'Aadhaar Number',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _aadhaarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '1234 5678 9012',
                prefixIcon: Icon(LucideIcons.fingerprint, size: 20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.lock,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Your data is directly fetched from UIDAI and is completely secure.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.push('/address-confirmation'),
              child: const Text('Verify with OTP'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'By continuing, you agree to our KYC terms',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
