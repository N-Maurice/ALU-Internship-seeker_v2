import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../models/startup_model.dart';
import '../../../providers/app_providers.dart';

final startupByIdProvider = FutureProvider.family<StartupModel?, String>((ref, id) {
  return ref.watch(startupRepositoryProvider).getById(id);
});

/// The signed-in founder's own startup — a founder owns exactly one in this
/// scope. `null` means they haven't finished founder onboarding yet.
final myStartupProvider = StreamProvider<StartupModel?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final startupRepo = ref.watch(startupRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand(
    (user) => user == null ? Stream.value(null) : startupRepo.streamMine(user.uid),
  );
});

/// Every startup awaiting admin review — read access is restricted to
/// admins by `firestore.rules`, so this only resolves usefully for them.
final pendingStartupsProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.watch(startupRepositoryProvider).streamPending();
});

final startupControllerProvider =
    NotifierProvider<StartupController, AsyncValue<void>>(StartupController.new);

class StartupController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> create(StartupModel startup) async {
    state = const AsyncLoading();
    try {
      await ref.read(startupRepositoryProvider).create(startup);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    try {
      await ref.read(startupRepositoryProvider).update(id, data);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  /// Admin-only in practice — enforced by `firestore.rules`, not here.
  Future<bool> setVerificationStatus(String id, VerificationStatus status) async {
    state = const AsyncLoading();
    try {
      await ref.read(startupRepositoryProvider).setVerificationStatus(id, status);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }
}
