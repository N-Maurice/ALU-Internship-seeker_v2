import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utilities/validators.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_widgets.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  int? _graduationYear;
  bool _agreedToTerms = false;
  bool _triedSubmit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _triedSubmit = true);
    final formValid = _formKey.currentState!.validate();
    if (!formValid || _graduationYear == null || !_agreedToTerms) return;

    await ref.read(authControllerProvider.notifier).signUp(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          graduationYear: _graduationYear!,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (next.hasError) {
        context.showSnack(next.error.toString(), isError: true);
      }
    });
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Row(
                      children: [
                        AppLogo(),
                        SizedBox(width: 10),
                        Text(
                          'ALU Venture Connect',
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your details to join the ALU Venture community.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    AuthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: 'Full Name',
                            controller: _nameController,
                            hint: 'John Doe',
                            icon: Icons.person_outline,
                            validator: Validators.fullName,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'ALU Email',
                            controller: _emailController,
                            hint: 'j.doe@alustudent.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.aluEmail,
                          ),
                          const SizedBox(height: 16),
                          Text('Graduation Year', style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<int>(
                            initialValue: _graduationYear,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.school_outlined),
                              hintText: 'Select Year',
                            ),
                            items: kGraduationYears
                                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                                .toList(),
                            onChanged: (v) => setState(() => _graduationYear = v),
                            validator: (v) => v == null ? 'Select your graduation year' : null,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            label: 'Password',
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: Validators.password,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                              ),
                              const Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 12),
                                  child: Text(
                                    'I agree to the Terms of Service and Privacy Policy.',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (_triedSubmit && !_agreedToTerms)
                            const Padding(
                              padding: EdgeInsets.only(left: 12, bottom: 8),
                              child: Text(
                                'You must accept the terms to continue',
                                style: TextStyle(color: AppColors.error, fontSize: 12),
                              ),
                            ),
                          const SizedBox(height: 8),
                          CustomButton(
                            label: 'Create Account  →',
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 18),
                          const AuthDivider(label: 'ALREADY HAVE AN ACCOUNT?'),
                          const SizedBox(height: 14),
                          CustomButton(
                            label: 'Sign In instead',
                            variant: ButtonVariant.outlined,
                            onPressed: () => context.go('/login'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Secure 256-bit SSL Encrypted.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
