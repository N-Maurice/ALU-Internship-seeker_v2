import 'package:alu_internship_seeker_ii/features/opportunities/providers/opportunity_provider.dart';
import 'package:alu_internship_seeker_ii/models/opportunity_model.dart';
import 'package:alu_internship_seeker_ii/repositories/opportunity_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-written in-memory double for [OpportunityRepository] — this is
/// the payoff of the repository-pattern layer: query logic can be tested
/// without ever touching Firestore.
class FakeOpportunityRepository implements OpportunityRepository {
  final opportunities = [
    OpportunityModel(
      id: 'remote-1',
      startupId: 's1',
      startupName: 'EcoFarm AI',
      title: 'Data Analyst Intern',
      description: 'Remote data role.',
      duration: '4 Months',
      location: 'Remote',
      workMode: WorkMode.remote,
      postedAt: DateTime(2026, 1, 2),
    ),
    OpportunityModel(
      id: 'onsite-1',
      startupId: 's2',
      startupName: 'Zuri Tech Solutions',
      title: 'Software Engineering Intern',
      description: 'On-site engineering role.',
      duration: '3 Months',
      location: 'Kigali',
      workMode: WorkMode.onSite,
      postedAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Stream<List<OpportunityModel>> streamOpportunities(OpportunityFilter filter) {
    var results = opportunities;
    if (filter.workMode != null) {
      results = results.where((o) => o.workMode == filter.workMode).toList();
    }
    return Stream.value(results);
  }

  @override
  Future<OpportunityModel?> getById(String id) async {
    for (final o in opportunities) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  Stream<List<OpportunityModel>> streamByIds(List<String> ids) =>
      Stream.value(opportunities.where((o) => ids.contains(o.id)).toList());
}

void main() {
  test('FakeOpportunityRepository filters by work mode', () async {
    final repo = FakeOpportunityRepository();

    final unfiltered = await repo.streamOpportunities(const OpportunityFilter()).first;
    expect(unfiltered, hasLength(2));

    final remoteOnly = await repo
        .streamOpportunities(const OpportunityFilter(workMode: WorkMode.remote))
        .first;
    expect(remoteOnly, hasLength(1));
    expect(remoteOnly.single.id, 'remote-1');
  });

  test('OpportunityFilterNotifier updates state through the provider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(opportunityFilterProvider).workMode, isNull);

    container.read(opportunityFilterProvider.notifier).setWorkMode(WorkMode.remote);
    expect(container.read(opportunityFilterProvider).workMode, WorkMode.remote);

    container.read(opportunityFilterProvider.notifier).clear();
    expect(container.read(opportunityFilterProvider).workMode, isNull);
  });

  test('OpportunityFilter.copyWith clears a value via the nullable setter', () {
    const filter = OpportunityFilter(workMode: WorkMode.hybrid, skill: 'Figma');
    final cleared = filter.copyWith(workMode: () => null);

    expect(cleared.workMode, isNull);
    expect(cleared.skill, 'Figma');
    expect(filter.isEmpty, isFalse);
    expect(const OpportunityFilter().isEmpty, isTrue);
  });
}
