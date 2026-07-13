import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class UserRepository {
  Stream<UserModel?> streamProfile(String uid);
  Future<void> createProfile(UserModel user);
  Future<void> updateProfile(String uid, Map<String, dynamic> data);
  Future<void> setSavedOpportunity(String uid, String opportunityId, bool saved);
}

class FirebaseUserRepository implements UserRepository {
  FirebaseUserRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Stream<UserModel?> streamProfile(String uid) => _users.doc(uid).snapshots().map(
        (snap) => snap.exists ? UserModel.fromMap(uid, snap.data()!) : null,
      );

  @override
  Future<void> createProfile(UserModel user) =>
      _users.doc(user.uid).set(user.toMap());

  @override
  Future<void> updateProfile(String uid, Map<String, dynamic> data) =>
      _users.doc(uid).update(data);

  @override
  Future<void> setSavedOpportunity(
    String uid,
    String opportunityId,
    bool saved,
  ) =>
      _users.doc(uid).update({
        'savedOpportunityIds': saved
            ? FieldValue.arrayUnion([opportunityId])
            : FieldValue.arrayRemove([opportunityId]),
      });
}
