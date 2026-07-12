import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/startup_model.dart';

/// Read-only in the student-facing phase — founders manage this data in a
/// later phase.
abstract class StartupRepository {
  Future<StartupModel?> getById(String id);
}

class FirebaseStartupRepository implements StartupRepository {
  FirebaseStartupRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<StartupModel?> getById(String id) async {
    final snap =
        await _firestore.collection(FirestoreCollections.startups).doc(id).get();
    return snap.exists ? StartupModel.fromMap(snap.id, snap.data()!) : null;
  }
}
