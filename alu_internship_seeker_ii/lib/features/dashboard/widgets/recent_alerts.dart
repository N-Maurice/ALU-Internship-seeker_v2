import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../providers/dashboard_provider.dart';

class RecentAlerts extends StatelessWidget {
  const RecentAlerts({super.key, required this.alerts});

  final List<DashboardAlert> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Text(
        'No updates yet — you\'ll see status changes here once startups review your applications.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < alerts.length; i++) ...[
          if (i > 0) const Divider(),
          _AlertTile(alerts[i]),
        ],
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile(this.alert);

  final DashboardAlert alert;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.mail_outline, color: AppColors.red, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                DateFormatter.relative(alert.time),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
