import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../providers/app_providers.dart';
import '../providers/auth_provider.dart';

/// Shown when a signed-in user hasn't verified their email yet. Polls every
/// few seconds so verifying in another tab/device is picked up without the
/// user needing to tap anything — the "I've verified" button is a manual
/// fallback for when polling is slow to notice.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  Timer? _pollTimer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _check());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _check() async {
    if (_checking) return;
    setState(() => _checking = true);
    final verified = await ref.read(authControllerProvider.notifier).refreshEmailVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (verified) {
      _pollTimer?.cancel();
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(firebaseAuthProvider).currentUser?.email ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'Verify your email',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Text(
                "We sent a verification link to $email. Click it, then come back here — this page checks automatically.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: "I've Verified My Email",
                isLoading: _checking,
                onPressed: _check,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Resend Verification Email',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).resendVerificationEmail();
                  context.showSnack('Verification email sent.');
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'Sign Out',
                variant: ButtonVariant.text,
                onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
