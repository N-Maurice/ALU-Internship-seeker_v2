import 'package:cloud_firestore/cloud_firestore.dart';

/// Lives at `conversations/{conversationId}/messages/{id}` — the parent
/// conversation already identifies the two participants, so nothing needs
/// denormalizing onto the message itself for the security rules to work.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderIsFounder,
    required this.text,
    required this.sentAt,
  });

  final String id;
  final String senderId;
  final bool senderIsFounder;
  final String text;
  final DateTime sentAt;

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) => MessageModel(
        id: id,
        senderId: map['senderId'] as String? ?? '',
        senderIsFounder: map['senderIsFounder'] as bool? ?? false,
        text: map['text'] as String? ?? '',
        sentAt: (map['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
