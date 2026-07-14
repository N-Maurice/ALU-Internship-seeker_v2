import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/colors.dart';
import '../../features/authentication/providers/auth_provider.dart';
import '../../features/authentication/widgets/auth_form_widgets.dart';
import '../components/profile_avatar.dart';
import '../extensions/context_extensions.dart';

/// The branded header shown on the founder shell's 3 tab-root screens
/// (Home, My Opportunities, Applicant Management) — logo + brand name +
/// "FOUNDER PORTAL" caption, notification bell, and the founder's own
/// avatar, matching the design spec's header treatment across those pages.
class FounderTopBar extends StatelessWidget implements PreferredSizeWidget {
  const FounderTopBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 12,
      title: Row(
        children: [
          const AppLogo(size: 32),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ALU Venture Connect',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                'FOUNDER PORTAL',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () =>
              context.showSnack('Notifications are coming in a future update.'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Consumer(
            builder: (context, ref, _) {
              final profile = ref.watch(currentUserProfileProvider).value;
              return ProfileAvatar(
                photoUrl: profile?.photoUrl,
                name: profile?.fullName ?? '',
                radius: 16,
              );
            },
          ),
        ),
      ],
    );
  }
}
