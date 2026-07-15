import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/user_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../authentication/providers/auth_provider.dart';
import '../providers/messaging_provider.dart';
import '../widgets/conversation_tile.dart';

/// Shared between both shells — the row shape (avatar, name, preview,
/// timestamp, unread badge) is identical between roles, only the data
/// source and empty-state copy differ.
class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(currentUserProfileProvider).value?.role;
    final isFounder = role == UserRole.founder;

    final conversationsAsync =
        isFounder ? ref.watch(founderConversationsProvider) : ref.watch(studentConversationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New message',
            onPressed: () => context.push('/messages/new'),
          ),
        ],
      ),
      body: conversationsAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => isFounder
              ? ref.invalidate(founderConversationsProvider)
              : ref.invalidate(studentConversationsProvider),
        ),
        data: (conversations) => conversations.isEmpty
            ? EmptyState(
                icon: Icons.forum_outlined,
                title: 'No conversations yet',
                message: isFounder
                    ? 'Tap the message icon above to start a conversation with an applicant.'
                    : 'Tap the message icon above to start a conversation with a startup.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: conversations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) =>
                    ConversationTile(conversation: conversations[i], isFounder: isFounder),
              ),
      ),
    );
  }
}
