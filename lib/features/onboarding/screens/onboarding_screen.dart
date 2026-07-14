import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/chip_input.dart';
import '../../authentication/providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _programController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _skills = <String>[];
  final _interests = <String>[];
  final _portfolioLinks = <String>[];
  bool _saving = false;

  @override
  void dispose() {
    _programController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_programController.text.trim().isEmpty) {
      context.showSnack('Enter your academic program', isError: true);
      return;
    }
    if (_skills.isEmpty) {
      context.showSnack('Add at least one skill', isError: true);
      return;
    }
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) {
      context.showSnack('You appear to be signed out. Please sign in again.', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(uid, {
        'program': _programController.text.trim(),
        'skills': _skills,
        'interests': _interests,
        'portfolioLinks': _portfolioLinks,
        'onboardingComplete': true,
      });
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not save your profile. Please try again.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tell us about yourself',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'This helps startups understand what you bring to the table, and helps us recommend the right opportunities.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Academic Program',
                controller: _programController,
                hint: 'e.g. BSc Software Engineering',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 20),
              ChipInput(
                label: 'Skills',
                values: _skills,
                hint: 'e.g. Flutter, Python, Figma',
                onChanged: (v) => setState(() {
                  _skills
                    ..clear()
                    ..addAll(v);
                }),
              ),
              const SizedBox(height: 20),
              ChipInput(
                label: 'Interests',
                values: _interests,
                hint: 'e.g. Fintech, UX Design, Data',
                onChanged: (v) => setState(() {
                  _interests
                    ..clear()
                    ..addAll(v);
                }),
              ),
              const SizedBox(height: 20),
              ChipInput(
                label: 'Portfolio Links',
                values: _portfolioLinks,
                hint: 'e.g. https://github.com/you',
                onChanged: (v) => setState(() {
                  _portfolioLinks
                    ..clear()
                    ..addAll(v);
                }),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: 'Finish Setup',
                isLoading: _saving,
                onPressed: _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
