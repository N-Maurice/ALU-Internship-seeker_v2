import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/application_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/messaging_repository.dart';
import '../repositories/opportunity_repository.dart';
import '../repositories/startup_repository.dart';
import '../repositories/user_repository.dart';

/// Repository-injection hub: the one place the app wires Firebase SDK
/// instances into the repository interfaces the rest of the app depends on.
/// UI -> Providers -> Repositories (this file) -> Firebase.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(ref.watch(firebaseAuthProvider)),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => FirebaseUserRepository(ref.watch(firestoreProvider)),
);

final opportunityRepositoryProvider = Provider<OpportunityRepository>(
  (ref) => FirebaseOpportunityRepository(ref.watch(firestoreProvider)),
);

final applicationRepositoryProvider = Provider<ApplicationRepository>(
  (ref) => FirebaseApplicationRepository(ref.watch(firestoreProvider)),
);

final startupRepositoryProvider = Provider<StartupRepository>(
  (ref) => FirebaseStartupRepository(ref.watch(firestoreProvider)),
);

final messagingRepositoryProvider = Provider<MessagingRepository>(
  (ref) => FirebaseMessagingRepository(ref.watch(firestoreProvider)),
);
