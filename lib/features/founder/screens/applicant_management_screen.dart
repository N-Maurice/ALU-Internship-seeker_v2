import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/application_model.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/founder_top_bar.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../applications/providers/application_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../widgets/applicant_status_style.dart';

class ApplicantManagementScreen extends ConsumerStatefulWidget {
  const ApplicantManagementScreen({super.key, this.opportunityId});

  final String? opportunityId;

  @override
  ConsumerState<ApplicantManagementScreen> createState() => _ApplicantManagementScreenState();
}

class _ApplicantManagementScreenState extends ConsumerState<ApplicantManagementScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.opportunityId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(applicantFilterProvider.notifier).setOpportunity(widget.opportunityId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allApplicantsAsync = ref.watch(applicantsForStartupProvider);
    final filteredAsync = ref.watch(filteredApplicantsProvider);
    final filter = ref.watch(applicantFilterProvider);
    final opportunities = ref.watch(myOpportunitiesProvider).value ?? const [];
    final allApplicants = allApplicantsAsync.value ?? const [];
    final today = DateTime.now();
    final newToday = allApplicants
        .where((a) =>
            a.appliedAt.year == today.year &&
            a.appliedAt.month == today.month &&
            a.appliedAt.day == today.day)
        .length;

    return Scaffold(
      appBar: const FounderTopBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Applicant Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review and manage student applications for your active ventures.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(label: 'TOTAL ACTIVE', value: '${allApplicants.length}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatBox(
                          label: 'NEW TODAY',
                          value: '$newToday',
                          valueColor: AppColors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: filter.opportunityId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          hint: const Text('All Opportunities'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Opportunities')),
                            for (final o in opportunities)
                              DropdownMenuItem(value: o.id, child: Text(o.title)),
                          ],
                          onChanged: (v) =>
                              ref.read(applicantFilterProvider.notifier).setOpportunity(v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<ApplicationStatus?>(
                          initialValue: filter.status,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          hint: const Text('All Statuses'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All Statuses')),
                            for (final s in ApplicationStatus.values)
                              DropdownMenuItem(value: s, child: Text(s.label)),
                          ],
                          onChanged: (v) => ref.read(applicantFilterProvider.notifier).setStatus(v),
                        ),
                      ),
                    ],
                  ),
                  if (filter.opportunityId != null || filter.status != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => ref.read(applicantFilterProvider.notifier).clear(),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Reset Filters'),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: filteredAsync.when(
                loading: () => const SkeletonList(),
                error: (error, _) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(applicantsForStartupProvider),
                ),
                data: (applicants) => applicants.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No applicants found',
                        message: 'Try a different filter, or check back once students apply.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: applicants.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          if (i == applicants.length) return const _BulkInviteCard();
                          return _ApplicantRow(application: applicants[i]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, letterSpacing: 0.6, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w700, color: valueColor)),
        ],
      ),
    );
  }
}

class _ApplicantRow extends ConsumerWidget {
  const _ApplicantRow({required this.application});

  final ApplicationModel application;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(studentProfileByIdProvider(application.studentId));
    final statusColor = applicantStatusColor(application.status);

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
          Row(
            children: [
              profileAsync.when(
                loading: () => const ProfileAvatar(name: '', radius: 18),
                error: (_, __) => const ProfileAvatar(name: '?', radius: 18),
                data: (profile) =>
                    ProfileAvatar(photoUrl: profile?.photoUrl, name: profile?.fullName ?? '?', radius: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: profileAsync.maybeWhen(
                            data: (profile) => Text(profile?.fullName ?? 'Unknown applicant',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            orElse: () => const Text('Loading...'),
                          ),
                        ),
                        Chip(
                          label: Text(application.status.label),
                          backgroundColor: statusColor.withValues(alpha: 0.12),
                          labelStyle: TextStyle(
                              color: statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    profileAsync.maybeWhen(
                      data: (profile) => Text(
                        profile?.program?.isNotEmpty == true
                            ? profile!.program!
                            : 'Program not set',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.work_outline, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(application.opportunityTitle,
                    style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('Applied ${DateFormatter.short(application.appliedAt)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'View Profile',
                  onPressed: () => context.push('/founder/applicants/${application.id}'),
                ),
              ),
              PopupMenuButton<ApplicationStatus>(
                icon: const Icon(Icons.more_vert),
                onSelected: (status) async {
                  final success = await ref
                      .read(applicationControllerProvider.notifier)
                      .updateStatus(application.id, status);
                  if (!success && context.mounted) {
                    context.showSnack('Could not update status.', isError: true);
                  }
                },
                itemBuilder: (context) => ApplicationStatus.values
                    .map((s) => PopupMenuItem(value: s, child: Text('Mark as ${s.label}')))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BulkInviteCard extends StatelessWidget {
  const _BulkInviteCard();

  @override
  Widget build(BuildContext context) {
    return DottedBorderCard(
      child: Column(
        children: [
          const Icon(Icons.group_add_outlined, size: 28, color: AppColors.textMuted),
          const SizedBox(height: 8),
          const Text('Bulk Invite Applicants', style: TextStyle(fontWeight: FontWeight.w600)),
          const Text('Import candidates from external lists',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Import Candidates',
            variant: ButtonVariant.outlined,
            onPressed: () =>
                context.showSnack('Bulk invite is coming in a future update.'),
          ),
        ],
      ),
    );
  }
}

/// A dashed-border container — plain `Container` doesn't support dashed
/// borders, so this paints one manually via `CustomPaint`.
class DottedBorderCard extends StatelessWidget {
  const DottedBorderCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.borderStrong
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
