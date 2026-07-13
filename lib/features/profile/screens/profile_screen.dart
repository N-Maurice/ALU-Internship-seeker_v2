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
import '../../../shared/widgets/chip_input.dart';
import '../../../shared/widgets/section_card.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final stats = ref.watch(applicationStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Venture Connect')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(child: ProfileAvatar(photoUrl: profile.photoUrl, name: profile.fullName, radius: 44)),
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
                Row(
                  children: [
                    _Metric('${stats.applied}', 'APPLICATIONS'),
                    _Metric('${stats.interviews}', 'INTERVIEWS'),
                    _Metric('${stats.offers}', 'ACCEPTED'),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.person_outline,
                        label: 'My Profile',
                        onTap: () => _showEditProfileSheet(context, ref, profile),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.star_border,
                        label: 'Skills & Interests',
                        onTap: () => _showSkillsSheet(context, ref, profile),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.bookmark_border,
                        label: 'Saved Opportunities',
                        onTap: () => context.push('/profile/saved'),
                      ),
                      const Divider(),
                      _MenuRow(
                        icon: Icons.notifications_none,
                        label: 'Notifications',
                        onTap: () => context.showSnack('Notifications are coming in a future update.'),
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
                if (profile.skills.length < 3) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Boost your visibility',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                'Adding ${3 - profile.skills.length} more skill${3 - profile.skills.length == 1 ? '' : 's'} to your profile increases your chance of being shortlisted.',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
        content: const Text('You can sign back in anytime with your ALU email.'),
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

  void _showEditProfileSheet(BuildContext context, WidgetRef ref, UserModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(profile: profile),
    );
  }

  void _showSkillsSheet(BuildContext context, WidgetRef ref, UserModel profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _SkillsSheet(profile: profile),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);

  final String value, label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, letterSpacing: 0.5)),
          ],
        ),
      );
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
      title: Text(label,
          style: TextStyle(color: isDestructive ? AppColors.error : AppColors.textPrimary, fontWeight: FontWeight.w500)),
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
  late final _programController = TextEditingController(text: widget.profile.program ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _programController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(widget.profile.uid, {
        'fullName': _nameController.text.trim(),
        'program': _programController.text.trim(),
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
          const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _programController,
            decoration: const InputDecoration(labelText: 'Academic Program'),
          ),
          const SizedBox(height: 20),
          CustomButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}

class _SkillsSheet extends ConsumerStatefulWidget {
  const _SkillsSheet({required this.profile});

  final UserModel profile;

  @override
  ConsumerState<_SkillsSheet> createState() => _SkillsSheetState();
}

class _SkillsSheetState extends ConsumerState<_SkillsSheet> {
  late var _skills = List<String>.from(widget.profile.skills);
  late var _interests = List<String>.from(widget.profile.interests);
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(userRepositoryProvider).updateProfile(widget.profile.uid, {
        'skills': _skills,
        'interests': _interests,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Skills & Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ChipInput(
              label: 'Skills',
              values: _skills,
              onChanged: (v) => setState(() => _skills = v),
            ),
            const SizedBox(height: 16),
            ChipInput(
              label: 'Interests',
              values: _interests,
              onChanged: (v) => setState(() => _interests = v),
            ),
            const SizedBox(height: 20),
            CustomButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
