import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Interview scheduling isn't modeled yet in this phase, so this is an
/// honest empty state rather than fabricated calendar events.
class UpcomingWidget extends StatelessWidget {
  const UpcomingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.event_available_outlined, color: AppColors.textMuted),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'No upcoming interviews yet. Scheduled interviews will appear here.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
