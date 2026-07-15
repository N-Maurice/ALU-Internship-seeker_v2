import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../models/conversation_model.dart';
import '../../../models/message_model.dart';
import '../../../providers/app_providers.dart';

/// A student's conversations, one row per startup they're talking to.
final studentConversationsProvider = StreamProvider<List<ConversationModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final repo = ref.watch(messagingRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand(
    (user) => user == null ? Stream.value(const <ConversationModel>[]) : repo.streamForStudent(user.uid),
  );
});

/// A founder's conversations, one row per student talking to their startup —
/// re-subscribes through auth -> startup exactly like `myOpportunitiesProvider`.
final founderConversationsProvider = StreamProvider<List<ConversationModel>>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final startupRepo = ref.watch(startupRepositoryProvider);
  final repo = ref.watch(messagingRepositoryProvider);
  return authRepo.authStateChanges.asyncExpand((user) {
    if (user == null) return Stream.value(const <ConversationModel>[]);
    return startupRepo.streamMine(user.uid).asyncExpand(
          (startup) => startup == null
              ? Stream.value(const <ConversationModel>[])
              : repo.streamForStartup(startup.id),
        );
  });
});

/// Messages for one conversation — screens using this must `ref.watch()`
/// it (not just `ref.read()`), or Riverpod may pause the underlying
/// Firestore subscription while nothing is actively listening.
final conversationMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.watch(messagingRepositoryProvider).streamMessages(conversationId);
});

final messagingControllerProvider =
    NotifierProvider<MessagingController, AsyncValue<void>>(MessagingController.new);

class MessagingController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> sendMessage({
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
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    state = const AsyncLoading();
    try {
      await ref.read(messagingRepositoryProvider).sendMessage(
            studentId: studentId,
            studentName: studentName,
            studentPhotoUrl: studentPhotoUrl,
            startupId: startupId,
            startupName: startupName,
            startupLogoUrl: startupLogoUrl,
            senderId: senderId,
            senderIsFounder: senderIsFounder,
            text: trimmed,
          );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(mapExceptionToFailure(e), st);
      return false;
    }
  }

  Future<void> markRead({
    required String studentId,
    required String startupId,
    required bool asStudent,
  }) async {
    try {
      await ref
          .read(messagingRepositoryProvider)
          .markRead(studentId: studentId, startupId: startupId, asStudent: asStudent);
    } catch (_) {
      // Best-effort — an unread badge staying stale isn't worth surfacing
      // an error over.
    }
  }
}
