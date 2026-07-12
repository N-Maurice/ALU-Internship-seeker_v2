import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alu_internship_seeker_ii/core/theme/colors.dart';
import 'package:alu_internship_seeker_ii/features/opportunities/providers/opportunity_provider.dart';
import 'package:alu_internship_seeker_ii/features/opportunities/widgets/opportunity_card.dart';
import 'package:alu_internship_seeker_ii/shared/widgets/custom_search_bar.dart';

class OpportunitiesScreen extends StatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  State<OpportunitiesScreen> createState() => _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends State<OpportunitiesScreen> {
  final _searchController = TextEditingController();
  final _filters = const ['All', 'Internship', 'Remote', 'On-site', 'Hybrid'];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OpportunityProvider>().loadOpportunities();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OpportunityProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Opportunities')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchBar(
              controller: _searchController,
              hint: 'Search opportunities',
              onChanged: provider.searchOpportunities,
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = filter == _selectedFilter;
                return FilterChip(
                  label: Text(filter),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                    provider.filterOpportunities(filter);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.opportunities.isEmpty
                    ? const Center(child: Text('No opportunities found.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: provider.opportunities.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) => OpportunityCard(
                          opportunity: provider.opportunities[index],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
