import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../applications/providers/application_provider.dart';
import '../widgets/applicant_card.dart';

class ApplicantsScreen extends ConsumerWidget {
  const ApplicantsScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(applicantsForOpportunityProvider(opportunityId));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: applicantsAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(applicantsForOpportunityProvider(opportunityId)),
        ),
        data: (applicants) => applicants.isEmpty
            ? const EmptyState(
                icon: Icons.people_outline,
                title: 'No applicants yet',
                message: 'Students who apply to this opportunity will show up here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: applicants.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => ApplicantCard(application: applicants[i]),
              ),
      ),
    );
  }
}
