import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/application_model.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../applications/providers/application_provider.dart';
import '../../authentication/providers/auth_provider.dart';

/// A founder's view of one applicant — distinct from the student-facing
/// `ApplicationCard`, since this needs to show *who applied* (name/email/
/// skills via [studentProfileByIdProvider]) rather than the application's
/// own opportunity/startup context, which the founder already knows.
class ApplicantCard extends ConsumerWidget {
  const ApplicantCard({super.key, required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileByIdProvider(application.studentId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          profileAsync.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const Text('Could not load applicant profile.'),
            data: (profile) {
              if (profile == null) return const Text('Applicant no longer available.');
              return Row(
                children: [
                  ProfileAvatar(photoUrl: profile.photoUrl, name: profile.fullName, radius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(profile.email,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (profile.skills.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: profile.skills
                                .map((s) => Chip(
                                      label: Text(s),
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                'Applied ${DateFormatter.relative(application.appliedAt)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              DropdownButton<ApplicationStatus>(
                value: application.status,
                underline: const SizedBox.shrink(),
                items: ApplicationStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                    .toList(),
                onChanged: (status) async {
                  if (status == null || status == application.status) return;
                  final success = await ref
                      .read(applicationControllerProvider.notifier)
                      .updateStatus(application.id, status);
                  if (success && context.mounted) {
                    context.showSnack('Status updated to ${status.label}.');
                  } else if (context.mounted) {
                    context.showSnack('Could not update this applicant\'s status.',
                        isError: true);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
