import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/app_constants.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class MessagingRepository {
  Stream<List<ConversationModel>> streamForStudent(String studentId);
  Stream<List<ConversationModel>> streamForStartup(String startupId);
  Stream<List<MessageModel>> streamMessages(String conversationId);

  Future<void> sendMessage({
    required String studentId,
    required String studentName,
    String? studentPhotoUrl,
    required String startupId,
    required String startupName,
    String? startupLogoUrl,
    required String senderId,
    required bool senderIsFounder,
    required String text,
  });

  Future<void> markRead({
    required String studentId,
    required String startupId,
    required bool asStudent,
  });
}

class FirebaseMessagingRepository implements MessagingRepository {
  FirebaseMessagingRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection(FirestoreCollections.conversations);

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection(FirestoreCollections.messages);

  String _conversationId(String studentId, String startupId) => '${studentId}_$startupId';

  @override
  Stream<List<ConversationModel>> streamForStudent(String studentId) => _conversations
      .where('studentId', isEqualTo: studentId)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ConversationModel.fromMap(d.id, d.data())).toList());

  @override
  Stream<List<ConversationModel>> streamForStartup(String startupId) => _conversations
      .where('startupId', isEqualTo: startupId)
      .orderBy('lastMessageAt', descending: true)
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => ConversationModel.fromMap(d.id, d.data())).toList());

  @override
  Stream<List<MessageModel>> streamMessages(String conversationId) => _messages
      .where('conversationId', isEqualTo: conversationId)
      .orderBy('sentAt')
      .snapshots()
      .map((snap) => snap.docs.map((d) => MessageModel.fromMap(d.id, d.data())).toList());

  @override
  Future<void> sendMessage({
    required String studentId,
    required String studentName,
    String? studentPhotoUrl,
    required String startupId,
    required String startupName,
    String? startupLogoUrl,
    required String senderId,
    required bool senderIsFounder,
    required String text,
  }) async {
    final conversationId = _conversationId(studentId, startupId);
    final now = Timestamp.now();
    final batch = _firestore.batch();

    // `set(..., merge: true)` on a doc that doesn't exist yet is evaluated
    // as a create by Firestore rules, and as an update otherwise — one call
    // handles "first message ever" and "every message after" identically,
    // no read-before-write needed. FieldValue.increment() is atomic on its
    // own even outside a transaction.
    batch.set(
      _conversations.doc(conversationId),
      {
        'studentId': studentId,
        'studentName': studentName,
        'studentPhotoUrl': studentPhotoUrl,
        'startupId': startupId,
        'startupName': startupName,
        'startupLogoUrl': startupLogoUrl,
        'lastMessageText': text,
        'lastMessageSenderId': senderId,
        'lastMessageAt': now,
        if (senderIsFounder)
          'studentUnreadCount': FieldValue.increment(1)
        else
          'founderUnreadCount': FieldValue.increment(1),
        if (senderIsFounder) 'founderLastReadAt': now else 'studentLastReadAt': now,
      },
      SetOptions(merge: true),
    );

    batch.set(_messages.doc(), {
      'conversationId': conversationId,
      'studentId': studentId,
      'startupId': startupId,
      'senderId': senderId,
      'senderIsFounder': senderIsFounder,
      'text': text,
      'sentAt': now,
    });

    await batch.commit();
  }

  @override
  Future<void> markRead({
    required String studentId,
    required String startupId,
    required bool asStudent,
  }) async {
    try {
      await _conversations.doc(_conversationId(studentId, startupId)).update({
        if (asStudent) 'studentUnreadCount': 0 else 'founderUnreadCount': 0,
        if (asStudent) 'studentLastReadAt': Timestamp.now() else 'founderLastReadAt': Timestamp.now(),
      });
    } on FirebaseException catch (e) {
      // A chat can be opened (and try to mark itself read) before any
      // message — and therefore any conversation document — exists yet.
      if (e.code != 'not-found') rethrow;
    }
  }
}
