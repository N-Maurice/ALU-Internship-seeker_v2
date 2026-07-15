import 'package:cloud_firestore/cloud_firestore.dart';

/// `studentId`/`startupId` are denormalized directly onto every message
/// (the same reasoning `ApplicationModel` already denormalizes `startupId`
/// rather than requiring a `get()` hop through another collection) — this
/// keeps the messages security rule self-contained on this document alone.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.studentId,
    required this.startupId,
    required this.senderId,
    required this.senderIsFounder,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String conversationId;
  final String studentId;
  final String startupId;
  final String senderId;
  final bool senderIsFounder;
  final String text;
  final DateTime sentAt;

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) => MessageModel(
        id: id,
        conversationId: map['conversationId'] as String? ?? '',
        studentId: map['studentId'] as String? ?? '',
        startupId: map['startupId'] as String? ?? '',
        senderId: map['senderId'] as String? ?? '',
        senderIsFounder: map['senderIsFounder'] as bool? ?? false,
        text: map['text'] as String? ?? '',
        sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'conversationId': conversationId,
        'studentId': studentId,
        'startupId': startupId,
        'senderId': senderId,
        'senderIsFounder': senderIsFounder,
        'text': text,
        'sentAt': Timestamp.fromDate(sentAt),
      };
}
