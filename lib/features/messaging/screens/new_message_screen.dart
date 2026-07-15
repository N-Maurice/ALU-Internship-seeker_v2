import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../models/application_model.dart';
import '../../../models/startup_model.dart';
import '../../../models/user_model.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../applications/providers/application_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../startups/providers/startup_provider.dart';

/// Lets either side start a brand-new conversation from the Messages tab,
/// rather than only being reachable via an opportunity/applicant screen.
/// A student picks from every startup on the platform; a founder picks from
/// students who have actually applied to their startup (their real
/// contacts — there's no general "browse all students" feature).
class NewMessageScreen extends ConsumerWidget {
  const NewMessageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProfile = ref.watch(currentUserProfileProvider).value;
    final isFounder = myProfile?.role == UserRole.founder;

    return Scaffold(
      appBar: AppBar(title: const Text('New Message')),
      body: myProfile == null
          ? const LoadingWidget()
          : isFounder
              ? const _ApplicantPicker()
              : _StartupPicker(myUid: myProfile.uid),
    );
  }
}

class _StartupPicker extends ConsumerWidget {
  const _StartupPicker({required this.myUid});

  final String myUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupsAsync = ref.watch(allStartupsProvider);
    return startupsAsync.when(
      loading: () => const SkeletonList(),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(allStartupsProvider),
      ),
      data: (startups) => startups.isEmpty
          ? const EmptyState(
              icon: Icons.business_outlined,
              title: 'No startups yet',
              message: 'Check back once startups join the platform.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: startups.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _StartupTile(startup: startups[i], myUid: myUid),
            ),
    );
  }
}

class _StartupTile extends StatelessWidget {
  const _StartupTile({required this.startup, required this.myUid});

  final StartupModel startup;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ProfileAvatar(photoUrl: startup.logoUrl, name: startup.name, radius: 22),
      title: Text(startup.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(startup.industry, style: const TextStyle(color: AppColors.textSecondary)),
      onTap: () => context.push('/chat/$myUid/${startup.id}'),
    );
  }
}

class _ApplicantPicker extends ConsumerWidget {
  const _ApplicantPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicantsForStartupProvider);
    return applicantsAsync.when(
      loading: () => const SkeletonList(),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(applicantsForStartupProvider),
      ),
      data: (applications) {
        final uniqueByStudent = <String, ApplicationModel>{};
        for (final a in applications) {
          uniqueByStudent.putIfAbsent(a.studentId, () => a);
        }
        final students = uniqueByStudent.values.toList();
        if (students.isEmpty) {
          return const EmptyState(
            icon: Icons.people_outline,
            title: 'No applicants yet',
            message: 'Once students apply to your opportunities, you can message them here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: students.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) => _ApplicantTile(application: students[i]),
        );
      },
    );
  }
}

class _ApplicantTile extends ConsumerWidget {
  const _ApplicantTile({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileByIdProvider(application.studentId));
    return profileAsync.when(
      loading: () => const ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(child: SizedBox.shrink()),
        title: Text('Loading...'),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        if (profile == null) return const SizedBox.shrink();
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ProfileAvatar(photoUrl: profile.photoUrl, name: profile.fullName, radius: 22),
          title: Text(profile.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('Applied for ${application.opportunityTitle}',
              style: const TextStyle(color: AppColors.textSecondary)),
          onTap: () => context.push('/chat/${application.studentId}/${application.startupId}'),
        );
      },
    );
  }
}
