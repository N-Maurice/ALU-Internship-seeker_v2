import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/startup_model.dart';

abstract class StartupRepository {
  Future<StartupModel?> getById(String id);

  /// A founder owns exactly one startup in this scope, so this streams at
  /// most one document.
  Stream<StartupModel?> streamMine(String ownerUid);

  /// All startups awaiting admin review.
  Stream<List<StartupModel>> streamPending();

  Future<String> create(StartupModel startup);
  Future<void> update(String id, Map<String, dynamic> data);

  /// Admin-only in practice — enforced by `firestore.rules`, not here.
  Future<void> setVerificationStatus(String id, VerificationStatus status);
}

class FirebaseStartupRepository implements StartupRepository {
  FirebaseStartupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _startups =>
      _firestore.collection(FirestoreCollections.startups);

  @override
  Future<StartupModel?> getById(String id) async {
    final snap = await _startups.doc(id).get();
    return snap.exists ? StartupModel.fromMap(snap.id, snap.data()!) : null;
  }

  @override
  Stream<StartupModel?> streamMine(String ownerUid) => _startups
      .where('ownerUid', isEqualTo: ownerUid)
      .limit(1)
      .snapshots()
      .map((snap) => snap.docs.isEmpty
          ? null
          : StartupModel.fromMap(snap.docs.first.id, snap.docs.first.data()));

  @override
  Stream<List<StartupModel>> streamPending() => _startups
      .where('verificationStatus', isEqualTo: VerificationStatus.pending.name)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => StartupModel.fromMap(d.id, d.data())).toList());

  @override
  Future<String> create(StartupModel startup) async {
    final docRef = await _startups.add(startup.toMap());
    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) =>
      _startups.doc(id).update(data);

  @override
  Future<void> setVerificationStatus(String id, VerificationStatus status) =>
      _startups.doc(id).update({'verificationStatus': status.name});
}
