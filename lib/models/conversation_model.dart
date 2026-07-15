import 'package:cloud_firestore/cloud_firestore.dart';

/// One thread per (student, startup) pair — a student applying to several
/// roles at the same startup still has just one conversation, like a real
/// recruiting inbox. Document id is the deterministic `'${studentId}_$startupId'`
/// (see `MessagingRepository`), which prevents duplicate threads without a
/// query-then-create race.
class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.studentPhotoUrl,
    required this.startupId,
    required this.startupName,
    this.startupLogoUrl,
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.studentUnreadCount = 0,
    this.founderUnreadCount = 0,
    this.studentLastReadAt,
    this.founderLastReadAt,
  });

  final String id;
  final String studentId;
  final String studentName;
  final String? studentPhotoUrl;
  final String startupId;
  final String startupName;
  final String? startupLogoUrl;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final int studentUnreadCount;
  final int founderUnreadCount;
  final DateTime? studentLastReadAt;
  final DateTime? founderLastReadAt;

  factory ConversationModel.fromMap(String id, Map<String, dynamic> map) => ConversationModel(
        id: id,
        studentId: map['studentId'] as String? ?? '',
        studentName: map['studentName'] as String? ?? '',
        studentPhotoUrl: map['studentPhotoUrl'] as String?,
        startupId: map['startupId'] as String? ?? '',
        startupName: map['startupName'] as String? ?? '',
        startupLogoUrl: map['startupLogoUrl'] as String?,
        lastMessageText: map['lastMessageText'] as String?,
        lastMessageSenderId: map['lastMessageSenderId'] as String?,
        lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
        studentUnreadCount: map['studentUnreadCount'] as int? ?? 0,
        founderUnreadCount: map['founderUnreadCount'] as int? ?? 0,
        studentLastReadAt: (map['studentLastReadAt'] as Timestamp?)?.toDate(),
        founderLastReadAt: (map['founderLastReadAt'] as Timestamp?)?.toDate(),
      );

  /// Unread count for whichever side is viewing — the ConversationTile
  /// picks the right field based on the viewer's role.
  int unreadCountFor({required bool isFounder}) =>
      isFounder ? founderUnreadCount : studentUnreadCount;
}
