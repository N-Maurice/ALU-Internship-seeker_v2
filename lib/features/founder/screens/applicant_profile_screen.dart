import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/application_model.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/section_card.dart';
import '../../applications/providers/application_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../widgets/applicant_status_style.dart';

class ApplicantProfileScreen extends ConsumerWidget {
  const ApplicantProfileScreen({super.key, required this.applicationId});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync = ref.watch(applicationByIdProvider(applicationId));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Profile')),
      body: applicationAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(applicationByIdProvider(applicationId)),
        ),
        data: (application) => application == null
            ? const EmptyState(icon: Icons.person_off_outlined, title: 'Application not found')
            : _ApplicantProfileContent(application: application),
      ),
    );
  }
}

class _ApplicantProfileContent extends ConsumerWidget {
  const _ApplicantProfileContent({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileByIdProvider(application.studentId));

    return profileAsync.when(
      loading: () => const LoadingWidget(),
      error: (error, _) => ErrorState(message: error.toString()),
      data: (profile) {
        if (profile == null) {
          return const EmptyState(
            icon: Icons.person_off_outlined,
            title: 'Applicant profile not available',
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: ProfileAvatar(photoUrl: profile.photoUrl, name: profile.fullName, radius: 40)),
            const SizedBox(height: 14),
            Center(
              child: Text(profile.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            Center(
              child: Text(profile.email, style: const TextStyle(color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                [
                  if (profile.program?.isNotEmpty == true) profile.program,
                  if (profile.graduationYear != null) 'Class of ${profile.graduationYear}',
                ].join(' · '),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
            SectionCard(
              title: 'Application',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(application.opportunityTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Applied ${DateFormatter.short(application.appliedAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  Text('Status', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ApplicationStatus>(
                    initialValue: application.status,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: applicantStatusColor(application.status).withValues(alpha: 0.08),
                    ),
                    items: ApplicationStatus.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                        .toList(),
                    onChanged: (status) async {
                      if (status == null || status == application.status) return;
                      final success = await ref
                          .read(applicationControllerProvider.notifier)
                          .updateStatus(application.id, status);
                      if (context.mounted) {
                        success
                            ? context.showSnack('Status updated to ${status.label}.')
                            : context.showSnack('Could not update status.', isError: true);
                      }
                    },
                  ),
                ],
              ),
            ),
            if (application.coverLetter?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'Cover Letter',
                child: Text(application.coverLetter!, style: const TextStyle(height: 1.6)),
              ),
            ],
            const SizedBox(height: 16),
            CustomButton(
              label: 'Message Applicant',
              onPressed: () =>
                  context.push('/chat/${application.studentId}/${application.startupId}'),
            ),
            if (profile.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'Skills',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.skills.map((s) => Chip(label: Text(s))).toList(),
                ),
              ),
            ],
            if (profile.portfolioLinks.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'Portfolio & Links',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final link in profile.portfolioLinks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => launchUrl(Uri.parse(link)),
                          child: Text(
                            link,
                            style: const TextStyle(
                              color: AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
