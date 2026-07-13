import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/opportunity_model.dart';
import '../../../providers/app_providers.dart';
import '../../../repositories/opportunity_repository.dart';

class OpportunityFilterNotifier extends Notifier<OpportunityFilter> {
  @override
  OpportunityFilter build() => const OpportunityFilter();

  void setQuery(String query) => state = state.copyWith(query: query);

  void setWorkMode(WorkMode? mode) => state = state.copyWith(workMode: () => mode);

  void setSkill(String? skill) => state = state.copyWith(skill: () => skill);

  void clear() => state = const OpportunityFilter();
}

final opportunityFilterProvider =
    NotifierProvider<OpportunityFilterNotifier, OpportunityFilter>(
  OpportunityFilterNotifier.new,
);

final opportunitiesStreamProvider = StreamProvider<List<OpportunityModel>>((ref) {
  final filter = ref.watch(opportunityFilterProvider);
  return ref.watch(opportunityRepositoryProvider).streamOpportunities(filter);
});

final opportunityByIdProvider =
    FutureProvider.family<OpportunityModel?, String>((ref, id) {
  return ref.watch(opportunityRepositoryProvider).getById(id);
});

/// Re-subscribes to the saved-opportunities stream whenever the signed-in
/// uid or its saved-id list changes, chaining two `asyncExpand` calls (auth
/// -> profile -> saved opportunities) directly off the repositories rather
/// than another provider's removed `.stream` modifier.
final savedOpportunitiesProvider = StreamProvider<List<OpportunityModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  final opportunityRepo = ref.watch(opportunityRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand((user) {
    if (user == null) return Stream.value(const <OpportunityModel>[]);
    return userRepo.streamProfile(user.uid).asyncExpand(
          (profile) => opportunityRepo.streamByIds(profile?.savedOpportunityIds ?? const []),
        );
  });
});
