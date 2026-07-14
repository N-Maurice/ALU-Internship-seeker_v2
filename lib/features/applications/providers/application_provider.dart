import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../models/application_model.dart';
import '../../../models/opportunity_model.dart';
import '../../../providers/app_providers.dart';
import '../../authentication/providers/auth_provider.dart';

final applicationsStreamProvider = StreamProvider<List<ApplicationModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final appRepo = ref.watch(applicationRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand(
    (user) => user == null ? Stream.value(const []) : appRepo.streamForStudent(user.uid),
  );
});

final hasAppliedProvider = FutureProvider.family<bool, String>((ref, opportunityId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) return Future.value(false);
  return ref.watch(applicationRepositoryProvider).hasApplied(user.uid, opportunityId);
});

final applicationByIdProvider = FutureProvider.family<ApplicationModel?, String>((ref, id) {
  return ref.watch(applicationRepositoryProvider).getById(id);
});

/// A founder's applicants for one of their own opportunities — read access
/// beyond that is blocked by `firestore.rules`.
final applicantsForOpportunityProvider =
    StreamProvider.family<List<ApplicationModel>, String>((ref, opportunityId) {
  return ref.watch(applicationRepositoryProvider).streamForOpportunity(opportunityId);
});

/// A founder's applicants across every opportunity their startup has posted,
/// re-subscribing through auth -> startup exactly like `myOpportunitiesProvider`.
final applicantsForStartupProvider = StreamProvider<List<ApplicationModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final startupRepo = ref.watch(startupRepositoryProvider);
  final appRepo = ref.watch(applicationRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand((user) {
    if (user == null) return Stream.value(const <ApplicationModel>[]);
    return startupRepo.streamMine(user.uid).asyncExpand(
          (startup) => startup == null
              ? Stream.value(const <ApplicationModel>[])
              : appRepo.streamForStartup(startup.id),
        );
  });
});

/// Local filter state for the founder's Applicant Management screen —
/// filtering happens client-side over `applicantsForStartupProvider`'s
/// already-scoped result set, no extra Firestore query needed.
class ApplicantFilter {
  const ApplicantFilter({this.opportunityId, this.status});

  final String? opportunityId;
  final ApplicationStatus? status;

  ApplicantFilter copyWith({
    String? Function()? opportunityId,
    ApplicationStatus? Function()? status,
  }) =>
      ApplicantFilter(
        opportunityId: opportunityId != null ? opportunityId() : this.opportunityId,
        status: status != null ? status() : this.status,
      );
}

class ApplicantFilterNotifier extends Notifier<ApplicantFilter> {
  @override
  ApplicantFilter build() => const ApplicantFilter();

  void setOpportunity(String? opportunityId) =>
      state = state.copyWith(opportunityId: () => opportunityId);

  void setStatus(ApplicationStatus? status) => state = state.copyWith(status: () => status);

  void clear() => state = const ApplicantFilter();
}

final applicantFilterProvider =
    NotifierProvider<ApplicantFilterNotifier, ApplicantFilter>(ApplicantFilterNotifier.new);

final filteredApplicantsProvider = Provider<AsyncValue<List<ApplicationModel>>>((ref) {
  final filter = ref.watch(applicantFilterProvider);
  return ref.watch(applicantsForStartupProvider).whenData((applicants) {
    return applicants.where((a) {
      final matchesOpportunity =
          filter.opportunityId == null || a.opportunityId == filter.opportunityId;
      final matchesStatus = filter.status == null || a.status == filter.status;
      return matchesOpportunity && matchesStatus;
    }).toList();
  });
});

final applicationControllerProvider =
    NotifierProvider<ApplicationController, AsyncValue<void>>(ApplicationController.new);

class ApplicationController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> apply(OpportunityModel opportunity) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return false;

    state = const AsyncLoading();
    try {
      final now = DateTime.now();
      await ref.read(applicationRepositoryProvider).apply(
            ApplicationModel(
              id: '',
              opportunityId: opportunity.id,
              opportunityTitle: opportunity.title,
              startupId: opportunity.startupId,
              startupName: opportunity.startupName,
              studentId: user.uid,
              appliedAt: now,
              updatedAt: now,
            ),
          );
      ref.invalidate(hasAppliedProvider(opportunity.id));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  /// Founder-only in practice — enforced by `firestore.rules`, not here.
  Future<bool> updateStatus(String applicationId, ApplicationStatus status) async {
    state = const AsyncLoading();
    try {
      await ref.read(applicationRepositoryProvider).updateStatus(applicationId, status);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }
}
