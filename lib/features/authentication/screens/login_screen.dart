import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/validators.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_widgets.dart';

const _rememberedEmailKey = 'remembered_email';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberDevice = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      final remembered = prefs.getString(_rememberedEmailKey);
      if (remembered != null && mounted) {
        setState(() {
          _emailController.text = remembered;
          _rememberDevice = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    if (_rememberDevice) {
      await prefs.setString(_rememberedEmailKey, _emailController.text.trim());
    } else {
      await prefs.remove(_rememberedEmailKey);
    }
    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
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
      backgroundColor: AppColors.background,
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
                    const SizedBox(height: 40),
                    const Center(child: AppLogo(size: 64)),
                    const SizedBox(height: 16),
                    const Text(
                      'ALU Venture Connect',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Connecting student ambition with startup opportunities.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    AuthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            label: 'Email Address',
                            controller: _emailController,
                            hint: 'student@alueducation.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Password'),
                              const Spacer(),
                              CustomButton(
                                label: 'Forgot Password?',
                                variant: ButtonVariant.text,
                                onPressed: () => context.push('/forgot-password'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          CustomTextField(
                            label: 'Password',
                            showLabel: false,
                            controller: _passwordController,
                            icon: Icons.lock_outline,
                            obscureText: true,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Password is required' : null,
                          ),
                          const SizedBox(height: 4),
                          CheckboxListTile(
                            value: _rememberDevice,
                            onChanged: (v) => setState(() => _rememberDevice = v ?? false),
                            title: const Text('Remember this device'),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                          const SizedBox(height: 8),
                          CustomButton(
                            label: 'Sign In',
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 14),
                          const AuthDivider(label: 'OR'),
                          const SizedBox(height: 14),
                          GoogleSignInButton(
                            isLoading: isLoading,
                            onPressed: () =>
                                ref.read(authControllerProvider.notifier).signInWithGoogle(),
                          ),
                          const SizedBox(height: 18),
                          const AuthDivider(label: 'New to the community?'),
                          const SizedBox(height: 14),
                          CustomButton(
                            label: 'Create an account',
                            variant: ButtonVariant.outlined,
                            onPressed: () => context.go('/signup'),
                          ),
                        ],
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
