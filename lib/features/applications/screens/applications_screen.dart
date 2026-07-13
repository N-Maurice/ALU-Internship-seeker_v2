import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/application_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/application_provider.dart';
import '../widgets/application_card.dart';

const _tabs = <String, Set<ApplicationStatus>>{
  'Applied': {ApplicationStatus.submitted, ApplicationStatus.underReview},
  'Interview': {ApplicationStatus.interview},
  'Accepted': {ApplicationStatus.accepted},
  'Rejected': {ApplicationStatus.rejected},
};

class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: _tabs.length, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs.keys.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: applicationsAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(applicationsStreamProvider),
        ),
        data: (applications) {
          if (applications.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_outlined,
              title: 'No applications yet',
              message: 'Explore opportunities and apply to start tracking them here.',
            );
          }
          return TabBarView(
            controller: _tabController,
            children: _tabs.values.map((statuses) {
              final filtered =
                  applications.where((a) => statuses.contains(a.status)).toList();
              if (filtered.isEmpty) {
                return const EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Nothing here yet',
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => ApplicationCard(application: filtered[i]),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
