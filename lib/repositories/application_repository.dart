import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/application_model.dart';

abstract class ApplicationRepository {
  Stream<List<ApplicationModel>> streamForStudent(String studentId);
  Future<bool> hasApplied(String studentId, String opportunityId);
  Future<void> apply(ApplicationModel application);
  Future<ApplicationModel?> getById(String id);

  /// Applicants for one of a founder's opportunities.
  Stream<List<ApplicationModel>> streamForOpportunity(String opportunityId);

  /// A founder's applicants across every opportunity their startup has posted.
  Stream<List<ApplicationModel>> streamForStartup(String startupId);

  Future<void> updateStatus(String applicationId, ApplicationStatus status);
}

class FirebaseApplicationRepository implements ApplicationRepository {
  FirebaseApplicationRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _applications =>
      _firestore.collection(FirestoreCollections.applications);

  @override
  Stream<List<ApplicationModel>> streamForStudent(String studentId) => _applications
      .where('studentId', isEqualTo: studentId)
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ApplicationModel.fromMap(d.id, d.data())).toList());

  @override
  Future<bool> hasApplied(String studentId, String opportunityId) async {
    final snap = await _applications
        .where('studentId', isEqualTo: studentId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  @override
  Future<void> apply(ApplicationModel application) =>
      _applications.add(application.toMap());

  @override
  Future<ApplicationModel?> getById(String id) async {
    final snap = await _applications.doc(id).get();
    return snap.exists ? ApplicationModel.fromMap(snap.id, snap.data()!) : null;
  }

  @override
  Stream<List<ApplicationModel>> streamForOpportunity(String opportunityId) => _applications
      .where('opportunityId', isEqualTo: opportunityId)
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ApplicationModel.fromMap(d.id, d.data())).toList());

  @override
  Stream<List<ApplicationModel>> streamForStartup(String startupId) => _applications
      .where('startupId', isEqualTo: startupId)
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ApplicationModel.fromMap(d.id, d.data())).toList());

  @override
  Future<void> updateStatus(String applicationId, ApplicationStatus status) =>
      _applications.doc(applicationId).update({
        'status': status.name,
        'updatedAt': Timestamp.now(),
      });
}
