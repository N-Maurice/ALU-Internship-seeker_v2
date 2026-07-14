import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/founder_top_bar.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../opportunities/providers/opportunity_provider.dart';

class MyOpportunitiesScreen extends ConsumerWidget {
  const MyOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(myOpportunitiesProvider);

    return Scaffold(
      appBar: const FounderTopBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/founder/opportunities/new'),
        backgroundColor: AppColors.navy,
        icon: const Icon(Icons.add),
        label: const Text('Post Opportunity'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: opportunitiesAsync.when(
                loading: () => const SkeletonList(),
                error: (error, _) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(myOpportunitiesProvider),
                ),
                data: (opportunities) => opportunities.isEmpty
                    ? const EmptyState(
                        icon: Icons.work_outline,
                        title: 'No opportunities posted yet',
                        message: 'Opportunities you post will appear here.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: opportunities.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _OpportunityTile(opportunity: opportunities[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpportunityTile extends ConsumerWidget {
  const _OpportunityTile({required this.opportunity});

  final OpportunityModel opportunity;

  (Color, String) get _statusStyle => switch (opportunity.status) {
        OpportunityStatus.open => (AppColors.success, 'Open'),
        OpportunityStatus.draft => (AppColors.textSecondary, 'Draft'),
        OpportunityStatus.closed => (AppColors.error, 'Closed'),
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (statusColor, statusLabel) = _statusStyle;
    return InkWell(
      onTap: () => context.push('/founder/applicants?opportunityId=${opportunity.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(opportunity.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(statusLabel),
                        backgroundColor: statusColor.withValues(alpha: 0.12),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                      ),
                      const SizedBox(width: 8),
                      Text(opportunity.workMode.label,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.navy),
              onPressed: () => context.push('/founder/opportunities/${opportunity.id}/edit'),
            ),
            if (!opportunity.isDraft)
              IconButton(
                icon: Icon(
                  opportunity.isOpen ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  color: AppColors.textSecondary,
                ),
                tooltip: opportunity.isOpen ? 'Close applications' : 'Reopen applications',
                onPressed: () async {
                  final success =
                      await ref.read(opportunityControllerProvider.notifier).setStatus(
                            opportunity.id,
                            opportunity.isOpen ? OpportunityStatus.closed : OpportunityStatus.open,
                          );
                  if (!success && context.mounted) {
                    context.showSnack('Could not update this opportunity.', isError: true);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
