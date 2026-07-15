import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/conversation_model.dart';
import '../../../shared/components/profile_avatar.dart';

/// A row in the conversation list — shows whichever side the *viewer*
/// isn't (student sees the startup, founder sees the student).
class ConversationTile extends StatelessWidget {
  const ConversationTile({super.key, required this.conversation, required this.isFounder});

  final ConversationModel conversation;
  final bool isFounder;

  @override
  Widget build(BuildContext context) {
    final name = isFounder ? conversation.studentName : conversation.startupName;
    final photoUrl = isFounder ? conversation.studentPhotoUrl : conversation.startupLogoUrl;
    final unread = conversation.unreadCountFor(isFounder: isFounder);

    return InkWell(
      onTap: () => context.push('/chat/${conversation.studentId}/${conversation.startupId}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            ProfileAvatar(photoUrl: photoUrl, name: name, radius: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                  Text(
                    conversation.lastMessageText ?? 'Say hello 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conversation.lastMessageAt != null)
                  Text(
                    DateFormatter.relative(conversation.lastMessageAt!),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                if (unread > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
