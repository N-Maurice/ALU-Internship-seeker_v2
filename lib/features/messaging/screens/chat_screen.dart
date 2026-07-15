import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../models/user_model.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../startups/providers/startup_provider.dart';
import '../providers/messaging_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.studentId, required this.startupId});

  final String studentId;
  final String startupId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  bool _markedRead = false;
  bool _sending = false;

  String get _conversationId => '${widget.studentId}_${widget.startupId}';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _maybeMarkRead(bool isFounder) {
    if (_markedRead) return;
    _markedRead = true;
    ref.read(messagingControllerProvider.notifier).markRead(
          studentId: widget.studentId,
          startupId: widget.startupId,
          asStudent: !isFounder,
        );
  }

  Future<void> _send({
    required String senderId,
    required bool senderIsFounder,
    required String studentName,
    String? studentPhotoUrl,
    required String startupName,
    String? startupLogoUrl,
  }) async {
    final text = _textController.text;
    if (text.trim().isEmpty || _sending) return;
    setState(() => _sending = true);
    _textController.clear();
    final success = await ref.read(messagingControllerProvider.notifier).sendMessage(
          studentId: widget.studentId,
          studentName: studentName,
          studentPhotoUrl: studentPhotoUrl,
          startupId: widget.startupId,
          startupName: startupName,
          startupLogoUrl: startupLogoUrl,
          senderId: senderId,
          senderIsFounder: senderIsFounder,
          text: text,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (!success) {
      context.showSnack('Could not send message. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myProfile = ref.watch(currentUserProfileProvider).value;
    final isFounder = myProfile?.role == UserRole.founder;
    final messagesAsync = ref.watch(conversationMessagesProvider(_conversationId));
    final studentAsync = ref.watch(studentProfileByIdProvider(widget.studentId));
    final startupAsync = ref.watch(startupByIdProvider(widget.startupId));

    if (myProfile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeMarkRead(isFounder);
      });
    }

    final headerName =
        isFounder ? (studentAsync.value?.fullName ?? '...') : (startupAsync.value?.name ?? '...');
    final headerPhoto = isFounder ? studentAsync.value?.photoUrl : startupAsync.value?.logoUrl;

    final canSend = myProfile != null && studentAsync.value != null && startupAsync.value != null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ProfileAvatar(photoUrl: headerPhoto, name: headerName, radius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(headerName, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const LoadingWidget(),
                error: (error, _) => ErrorState(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(conversationMessagesProvider(_conversationId)),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return const EmptyState(
                      icon: Icons.forum_outlined,
                      title: 'Say hello 👋',
                      message: 'Send the first message to start the conversation.',
                    );
                  }
                  final reversed = messages.reversed.toList();
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: reversed.length,
                    itemBuilder: (_, i) => MessageBubble(
                      text: reversed[i].text,
                      sentAt: reversed[i].sentAt,
                      isMine: reversed[i].senderId == myProfile?.uid,
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (canSend) {
                            _send(
                              senderId: myProfile.uid,
                              senderIsFounder: isFounder,
                              studentName: studentAsync.value!.fullName,
                              studentPhotoUrl: studentAsync.value!.photoUrl,
                              startupName: startupAsync.value!.name,
                              startupLogoUrl: startupAsync.value!.logoUrl,
                            );
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          filled: true,
                          fillColor: AppColors.background,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.navy),
                      icon: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      onPressed: canSend
                          ? () => _send(
                                senderId: myProfile.uid,
                                senderIsFounder: isFounder,
                                studentName: studentAsync.value!.fullName,
                                studentPhotoUrl: studentAsync.value!.photoUrl,
                                startupName: startupAsync.value!.name,
                                startupLogoUrl: startupAsync.value!.logoUrl,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
