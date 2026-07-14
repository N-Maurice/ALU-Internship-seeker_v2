import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/founder_top_bar.dart';
import '../../../shared/widgets/section_card.dart';
import '../../authentication/providers/auth_provider.dart';

class FounderProfileScreen extends ConsumerWidget {
  const FounderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: const FounderTopBar(),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: ProfileAvatar(
                      photoUrl: profile.photoUrl, name: profile.fullName, radius: 44),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(profile.fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ),
                Center(
                  child: Text(profile.email,
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 22),
                SectionCard(
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.business_outlined,
                        label: 'My Startup',
                        onTap: () => context.push('/founder/startup'),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.person_outline,
                        label: 'Edit Personal Details',
                        onTap: () => _showEditProfileSheet(context, profile),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.notifications_none,
                        label: 'Notifications',
                        onTap: () =>
                            context.showSnack('Notifications are coming in a future update.'),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.help_outline,
                        label: 'Help & Support',
                        onTap: () => launchUrl(
                          Uri(scheme: 'mailto', path: 'support@aluventureconnect.com'),
                        ),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.logout,
                        label: 'Logout',
                        isDestructive: true,
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in anytime with your email.'),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('Log Out')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  void _showEditProfileSheet(BuildContext context, UserModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.navy;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: isDestructive ? AppColors.error : AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final UserModel profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final _nameController = TextEditingController(text: widget.profile.fullName);
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(widget.profile.uid, {
        'fullName': _nameController.text.trim(),
      });
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) context.showSnack('Could not save changes.', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Edit Personal Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 20),
          CustomButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
