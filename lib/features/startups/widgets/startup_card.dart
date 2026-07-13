import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../models/startup_model.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/profile_avatar.dart';

/// The "About [Startup]" summary panel shown on an opportunity's detail
/// page, with a link through to the startup's full profile.
class StartupCard extends StatelessWidget {
  const StartupCard({super.key, required this.startup});

  final StartupModel startup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(photoUrl: startup.logoUrl, name: startup.name, radius: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text('About ${startup.name}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              if (startup.isVerified)
                const Icon(Icons.verified, color: AppColors.navy, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            startup.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'View Startup Profile',
            variant: ButtonVariant.text,
            onPressed: () => context.push('/startups/${startup.id}'),
          ),
        ],
      ),
    );
  }
}
