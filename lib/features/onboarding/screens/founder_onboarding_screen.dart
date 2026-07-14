import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../models/startup_model.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../startups/providers/startup_provider.dart';

class FounderOnboardingScreen extends ConsumerStatefulWidget {
  const FounderOnboardingScreen({super.key});

  @override
  ConsumerState<FounderOnboardingScreen> createState() => _FounderOnboardingScreenState();
}

class _FounderOnboardingScreenState extends ConsumerState<FounderOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _industryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) {
      context.showSnack('You appear to be signed out. Please sign in again.', isError: true);
      return;
    }

    setState(() => _saving = true);
    final created = await ref.read(startupControllerProvider.notifier).create(
          StartupModel(
            id: '',
            name: _nameController.text.trim(),
            industry: _industryController.text.trim(),
            description: _descriptionController.text.trim(),
            ownerUid: uid,
          ),
        );
    if (!created) {
      if (mounted) {
        context.showSnack('Could not register your startup. Please try again.',
            isError: true);
        setState(() => _saving = false);
      }
      return;
    }

    try {
      await ref.read(userRepositoryProvider).updateProfile(uid, {'onboardingComplete': true});
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
      appBar: AppBar(title: const Text('Register Your Startup')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tell us about your startup',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Your startup will need to be approved by an ALU admin before you can post opportunities — you'll see its status on your Startup Profile tab once you're in.",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Startup Name',
                  controller: _nameController,
                  hint: 'e.g. Nexus Analytics',
                  icon: Icons.rocket_launch_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your startup name' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Industry',
                  controller: _industryController,
                  hint: 'e.g. Fintech, Healthtech, EdTech',
                  icon: Icons.business_center_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an industry' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hint: 'What does your startup do?',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a short description' : null,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  label: 'Register Startup',
                  isLoading: _saving,
                  onPressed: _finish,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
