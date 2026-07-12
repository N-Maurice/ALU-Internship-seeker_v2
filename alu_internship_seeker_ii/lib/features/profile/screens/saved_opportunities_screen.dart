import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../opportunities/widgets/opportunity_card.dart';

class SavedOpportunitiesScreen extends ConsumerWidget {
  const SavedOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedOpportunitiesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Opportunities')),
      body: savedAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(savedOpportunitiesProvider),
        ),
        data: (opportunities) => opportunities.isEmpty
            ? const EmptyState(
                icon: Icons.bookmark_border,
                title: 'No saved opportunities',
                message: 'Tap the bookmark icon on any opportunity to save it for later.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: opportunities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => OpportunityCard(opportunity: opportunities[i]),
              ),
      ),
    );
  }
}
