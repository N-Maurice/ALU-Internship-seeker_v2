import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/components/custom_button.dart';
import '../widgets/auth_form_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
              child: Column(
                children: [
                  const Spacer(),
                  const AppLogo(size: 76),
                  const SizedBox(height: 32),
                  const Text(
                    'ALU Venture Connect',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Connecting ALU talent with high-\nimpact ventures.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, color: AppColors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.groups_rounded, color: AppColors.navy, size: 56),
                    ),
                  ),
                  const SizedBox(height: 40),
                  CustomButton(
                    label: 'Get Started  →',
                    onPressed: () => context.go('/signup'),
                  ),
                  const SizedBox(height: 4),
                  CustomButton(
                    label: 'I already have an account',
                    variant: ButtonVariant.text,
                    onPressed: () => context.go('/login'),
                  ),
                  const Spacer(),
                  const Text(
                    'PART OF THE ALU ECOSYSTEM',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
