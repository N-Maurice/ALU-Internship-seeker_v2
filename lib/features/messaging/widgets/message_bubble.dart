import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.sentAt, required this.isMine});

  final String text;
  final DateTime sentAt;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.navy : Colors.white,
          border: isMine ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMine ? 14 : 2),
            bottomRight: Radius.circular(isMine ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(color: isMine ? Colors.white : AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormatter.relative(sentAt),
              style: TextStyle(
                fontSize: 10,
                color: isMine ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
