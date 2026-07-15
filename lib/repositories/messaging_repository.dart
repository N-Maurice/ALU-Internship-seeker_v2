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

  /// Messages live under their conversation rather than a top-level
  /// collection filtered by `conversationId`. Firestore can only validate a
  /// *list* query against a rule that reads data outside the query's own
  /// filters when that data comes from a get() on a document reachable via
  /// the request path (the parent conversation, here) — a top-level
  /// collection filtered by `conversationId` while the rule checks
  /// `resource.data.studentId` (a different, unfiltered field) is provably
  /// unscoped, so Firestore hard-denies every such query with
  /// PERMISSION_DENIED regardless of what the data actually is.
  CollectionReference<Map<String, dynamic>> _messagesOf(String conversationId) =>
      _conversations.doc(conversationId).collection(FirestoreCollections.messages);

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
  Stream<List<MessageModel>> streamMessages(String conversationId) => _messagesOf(conversationId)
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

    // A plain WriteBatch won't work here: the message's create rule needs
    // to get() the parent conversation doc to confirm the sender is a
    // participant, but on the very first message ever, that doc is being
    // created in this same write — and get() calls in rules only see
    // writes from *earlier in the same transaction*, never sibling writes
    // in a plain batch. A transaction is what makes the conversation
    // write visible to the message rule's get() when both happen together.
    await _firestore.runTransaction((transaction) async {
      transaction.set(
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

      transaction.set(_messagesOf(conversationId).doc(), {
        'senderId': senderId,
        'senderIsFounder': senderIsFounder,
        'text': text,
        'sentAt': now,
      });
    });
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
