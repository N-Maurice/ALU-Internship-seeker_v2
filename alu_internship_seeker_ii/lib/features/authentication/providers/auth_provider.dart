import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failure.dart';
import '../../../models/user_model.dart';
import '../../../providers/app_providers.dart';

/// Raw Firebase auth identity (uid/email/emailVerified). `null` means signed out.
final authStateChangesProvider =
    StreamProvider<User?>((ref) => ref.watch(authRepositoryProvider).authStateChanges);

/// The signed-in user's Firestore profile, re-subscribing whenever the
/// signed-in uid changes (via `asyncExpand`, so the previous profile stream
/// is torn down cleanly on sign-out/sign-in instead of leaking a listener).
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand(
    (user) => user == null ? Stream.value(null) : userRepo.streamProfile(user.uid),
  );
});

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
    required int graduationYear,
  }) async {
    state = const AsyncLoading();
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final credential = await authRepo.signUp(email: email, password: password);
      final uid = credential.user!.uid;
      await ref.read(userRepositoryProvider).createProfile(
            UserModel(
              uid: uid,
              email: email,
              fullName: fullName,
              graduationYear: graduationYear,
              createdAt: DateTime.now(),
            ),
          );
      await authRepo.sendEmailVerification();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<void> signOut() => ref.read(authRepositoryProvider).signOut();

  Future<bool> sendPasswordResetEmail(String email) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await ref.read(authRepositoryProvider).sendEmailVerification();
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
    }
  }

  /// Reloads the Firebase user and reports whether their email is now
  /// verified — used by the "I've verified my email" polling screen.
  Future<bool> refreshEmailVerified() async {
    final authRepo = ref.read(authRepositoryProvider);
    try {
      await authRepo.reloadCurrentUser();
      return authRepo.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  Failure? get failure => state.hasError ? state.error as Failure : null;
}
