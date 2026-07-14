import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../../../models/startup_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/section_card.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../startups/providers/startup_provider.dart';

class MyOpportunitiesScreen extends ConsumerWidget {
  const MyOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(myStartupProvider);
    final opportunitiesAsync = ref.watch(myOpportunitiesProvider);
    final isVerified = startupAsync.value?.isVerified ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('My Opportunities')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isVerified ? () => context.push('/founder/opportunities/new') : null,
        backgroundColor: isVerified ? AppColors.navy : AppColors.textMuted,
        icon: const Icon(Icons.add),
        label: const Text('Post Opportunity'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!isVerified)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SectionCard(
                  child: Row(
                    children: [
                      Icon(
                        startupAsync.value?.verificationStatus == VerificationStatus.rejected
                            ? Icons.cancel_outlined
                            : Icons.hourglass_top_outlined,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          startupAsync.value?.verificationStatus == VerificationStatus.rejected
                              ? 'Your startup was not approved. Check your Startup Profile tab for details.'
                              : "Your startup is pending admin approval. You'll be able to post once it's approved.",
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => context.push('/founder/opportunities/${opportunity.id}/applicants'),
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
                        label: Text(opportunity.isOpen ? 'Open' : 'Closed'),
                        backgroundColor:
                            opportunity.isOpen ? AppColors.successLight : AppColors.border,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: opportunity.isOpen ? AppColors.success : AppColors.textSecondary,
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
            IconButton(
              icon: Icon(
                opportunity.isOpen ? Icons.pause_circle_outline : Icons.play_circle_outline,
                color: AppColors.textSecondary,
              ),
              tooltip: opportunity.isOpen ? 'Close applications' : 'Reopen applications',
              onPressed: () => ref.read(opportunityControllerProvider.notifier).setStatus(
                    opportunity.id,
                    opportunity.isOpen ? OpportunityStatus.closed : OpportunityStatus.open,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
