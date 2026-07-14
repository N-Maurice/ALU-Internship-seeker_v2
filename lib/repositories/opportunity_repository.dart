import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/opportunity_model.dart';

/// Local, in-memory filter/search state — Firestore has no full-text search,
/// so the work-mode filter is pushed down as a query and free-text search is
/// applied client-side over the (small, student-facing) result set.
class OpportunityFilter {
  const OpportunityFilter({this.query = '', this.workMode, this.skill});

  final String query;
  final WorkMode? workMode;
  final String? skill;

  bool get isEmpty => query.isEmpty && workMode == null && skill == null;

  OpportunityFilter copyWith({
    String? query,
    WorkMode? Function()? workMode,
    String? Function()? skill,
  }) =>
      OpportunityFilter(
        query: query ?? this.query,
        workMode: workMode != null ? workMode() : this.workMode,
        skill: skill != null ? skill() : this.skill,
      );
}

abstract class OpportunityRepository {
  Stream<List<OpportunityModel>> streamOpportunities(OpportunityFilter filter);
  Future<OpportunityModel?> getById(String id);
  Stream<List<OpportunityModel>> streamByIds(List<String> ids);

  /// A founder's own postings, newest first, regardless of open/closed status.
  Stream<List<OpportunityModel>> streamForStartup(String startupId);

  Future<String> create(OpportunityModel opportunity);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> setStatus(String id, OpportunityStatus status);
}

class FirebaseOpportunityRepository implements OpportunityRepository {
  FirebaseOpportunityRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _opportunities =>
      _firestore.collection(FirestoreCollections.opportunities);

  @override
  Stream<List<OpportunityModel>> streamOpportunities(OpportunityFilter filter) {
    Query<Map<String, dynamic>> q =
        _opportunities.where('status', isEqualTo: OpportunityStatus.open.name);
    if (filter.workMode != null) {
      q = q.where('workMode', isEqualTo: filter.workMode!.name);
    }
    return q.orderBy('postedAt', descending: true).snapshots().map((snap) {
      var results = snap.docs
          .map((d) => OpportunityModel.fromMap(d.id, d.data()))
          .toList();
      if (filter.query.isNotEmpty) {
        final q = filter.query.toLowerCase();
        results = results
            .where((o) =>
                o.title.toLowerCase().contains(q) ||
                o.startupName.toLowerCase().contains(q))
            .toList();
      }
      if (filter.skill != null) {
        results = results
            .where((o) => o.requiredSkills.contains(filter.skill))
            .toList();
      }
      return results;
    });
  }

  @override
  Future<OpportunityModel?> getById(String id) async {
    final snap = await _opportunities.doc(id).get();
    return snap.exists ? OpportunityModel.fromMap(snap.id, snap.data()!) : null;
  }

  @override
  Stream<List<OpportunityModel>> streamByIds(List<String> ids) {
    if (ids.isEmpty) return Stream.value(const []);
    // Firestore whereIn caps at 30 values, which comfortably covers a
    // student's saved-opportunities list.
    return _opportunities
        .where(FieldPath.documentId, whereIn: ids.take(30).toList())
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OpportunityModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Stream<List<OpportunityModel>> streamForStartup(String startupId) => _opportunities
      .where('startupId', isEqualTo: startupId)
      .orderBy('postedAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => OpportunityModel.fromMap(d.id, d.data())).toList());

  @override
  Future<String> create(OpportunityModel opportunity) async {
    final docRef = await _opportunities.add(opportunity.toMap());
    return docRef.id;
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) =>
      _opportunities.doc(id).update(data);

  @override
  Future<void> setStatus(String id, OpportunityStatus status) =>
      _opportunities.doc(id).update({'status': status.name});
}
