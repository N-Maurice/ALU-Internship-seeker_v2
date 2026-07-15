import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../../../models/opportunity_model.dart';
import '../../../providers/app_providers.dart';
import '../../../repositories/opportunity_repository.dart';

/// Firestore writes here go through a rule that requires a server-side
/// `get()` (checking startup ownership), so they can't be satisfied from
/// local cache while offline — they'll otherwise hang indefinitely on a
/// flaky connection instead of failing. This bounds that wait so the UI
/// can show a real error instead of spinning forever.
const _writeTimeout = Duration(seconds: 20);

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

/// The signed-in founder's own postings, re-subscribing through their
/// startup — a founder has no postings until `myStartupProvider` resolves.
final myOpportunitiesProvider = StreamProvider<List<OpportunityModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final startupRepo = ref.watch(startupRepositoryProvider);
  final opportunityRepo = ref.watch(opportunityRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand((user) {
    if (user == null) return Stream.value(const <OpportunityModel>[]);
    return startupRepo.streamMine(user.uid).asyncExpand(
          (startup) => startup == null
              ? Stream.value(const <OpportunityModel>[])
              : opportunityRepo.streamForStartup(startup.id),
        );
  });
});

final opportunityControllerProvider =
    NotifierProvider<OpportunityController, AsyncValue<void>>(OpportunityController.new);

class OpportunityController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(OpportunityModel opportunity) async {
    state = const AsyncLoading();
    try {
      await ref.read(opportunityRepositoryProvider).create(opportunity).timeout(_writeTimeout);
      state = const AsyncData(null);
      return true;
    } on TimeoutException catch (_, st) {
      state = AsyncError(const Failure('Taking too long to reach the server. Check your connection and try again.'), st);
      return false;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await ref.read(opportunityRepositoryProvider).update(id, data).timeout(_writeTimeout);
      state = const AsyncData(null);
      return true;
    } on TimeoutException catch (_, st) {
      state = AsyncError(const Failure('Taking too long to reach the server. Check your connection and try again.'), st);
      return false;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<bool> setStatus(String id, OpportunityStatus status) async {
    state = const AsyncLoading();
    try {
      await ref.read(opportunityRepositoryProvider).setStatus(id, status).timeout(_writeTimeout);
      state = const AsyncData(null);
      return true;
    } on TimeoutException catch (_, st) {
      state = AsyncError(const Failure('Taking too long to reach the server. Check your connection and try again.'), st);
      return false;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }
}
