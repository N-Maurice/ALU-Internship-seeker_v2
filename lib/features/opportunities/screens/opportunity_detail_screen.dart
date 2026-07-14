import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/opportunity_model.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../applications/providers/application_provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../startups/providers/startup_provider.dart';
import '../../startups/widgets/startup_card.dart';
import '../providers/opportunity_provider.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  const OpportunityDetailScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityAsync = ref.watch(opportunityByIdProvider(opportunityId));

    return Scaffold(
      body: SafeArea(
        child: opportunityAsync.when(
          loading: () => const LoadingWidget(),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(opportunityByIdProvider(opportunityId)),
          ),
          data: (opportunity) => opportunity == null
              ? const EmptyState(
                  icon: Icons.search_off,
                  title: 'Opportunity not found',
                  message: 'This listing may have been closed or removed.',
                )
              : _DetailContent(opportunity: opportunity),
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.opportunity});

  final OpportunityModel opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final isSaved = profile?.savedOpportunityIds.contains(opportunity.id) ?? false;
    final hasApplied = ref.watch(hasAppliedProvider(opportunity.id)).value ?? false;
    final applying = ref.watch(applicationControllerProvider).isLoading;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.navy),
              ),
              const Spacer(),
              if (profile != null)
                IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () async {
                    try {
                      await ref.read(userRepositoryProvider).setSavedOpportunity(
                            profile.uid,
                            opportunity.id,
                            !isSaved,
                          );
                    } catch (_) {
                      if (context.mounted) {
                        context.showSnack('Could not update saved opportunities.',
                            isError: true);
                      }
                    }
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              Text(
                opportunity.title,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: () => context.push('/startups/${opportunity.startupId}'),
                child: Text(
                  opportunity.startupName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _MetricTile(Icons.place_outlined, 'Location', opportunity.location),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      Icons.business_center_outlined,
                      'Work Mode',
                      opportunity.workMode.label,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child:
                        _MetricTile(Icons.schedule_outlined, 'Duration', opportunity.duration),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricTile(
                      Icons.calendar_today_outlined,
                      'Deadline',
                      opportunity.deadline == null
                          ? 'Rolling'
                          : DateFormatter.short(opportunity.deadline!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('About the Role',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(opportunity.description, style: const TextStyle(height: 1.6)),
              if (opportunity.requiredSkills.isNotEmpty) ...[
                const SizedBox(height: 28),
                const Text('Requirements & Skills',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.requiredSkills.map((s) => Chip(label: Text(s))).toList(),
                ),
              ],
              const SizedBox(height: 28),
              Consumer(
                builder: (context, ref, _) {
                  final startupAsync =
                      ref.watch(startupByIdProvider(opportunity.startupId));
                  return startupAsync.maybeWhen(
                    data: (startup) =>
                        startup == null ? const SizedBox.shrink() : StartupCard(startup: startup),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              label: !opportunity.isOpen
                  ? 'Applications Closed'
                  : hasApplied
                      ? 'Already Applied'
                      : 'Apply Now  ▷',
              isLoading: applying,
              onPressed: !opportunity.isOpen || hasApplied
                  ? null
                  : () => _confirmApply(context, ref),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmApply(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply to this opportunity?'),
        content: Text(
          'Your profile skills and portfolio links will be shared with ${opportunity.startupName}.',
        ),
        actions: [
          TextButton(onPressed: () => context.pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => context.pop(true), child: const Text('Apply')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await ref.read(applicationControllerProvider.notifier).apply(opportunity);
    if (!context.mounted) return;
    if (success) {
      context.showSnack('Application submitted to ${opportunity.startupName}!');
    } else {
      context.showSnack(
        ref.read(applicationControllerProvider).error.toString(),
        isError: true,
      );
    }
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.navy, size: 20),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
