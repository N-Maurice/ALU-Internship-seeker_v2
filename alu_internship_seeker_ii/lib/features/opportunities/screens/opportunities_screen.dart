import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/custom_search_bar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/opportunity_provider.dart';
import '../widgets/filter_widget.dart';
import '../widgets/opportunity_card.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opportunitiesAsync = ref.watch(opportunitiesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Opportunities')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hint: 'Search opportunities...',
                  onChanged: (v) =>
                      ref.read(opportunityFilterProvider.notifier).setQuery(v),
                ),
                const SizedBox(height: 12),
                const OpportunityFilterBar(),
              ],
            ),
          ),
          Expanded(
            child: opportunitiesAsync.when(
              loading: () => const SkeletonList(),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(opportunitiesStreamProvider),
              ),
              data: (opportunities) => opportunities.isEmpty
                  ? const EmptyState(
                      icon: Icons.search_off,
                      title: 'No opportunities found',
                      message: 'Try a different search term or filter.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: opportunities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, index) =>
                          OpportunityCard(opportunity: opportunities[index]),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
