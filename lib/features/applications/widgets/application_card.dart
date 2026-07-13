import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  const ApplicationCard({super.key, required this.application});

  final ApplicationModel application;

  Color get _statusColor => switch (application.status) {
        ApplicationStatus.submitted => AppColors.textSecondary,
        ApplicationStatus.underReview => AppColors.warning,
        ApplicationStatus.interview => AppColors.navy,
        ApplicationStatus.accepted => AppColors.success,
        ApplicationStatus.rejected => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.rocket_launch_outlined, color: AppColors.navy),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(application.opportunityTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(application.startupName,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                'Applied ${DateFormatter.relative(application.appliedAt)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              Chip(
                label: Text(application.status.label.toUpperCase()),
                labelStyle: TextStyle(
                  color: _statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: _statusColor.withValues(alpha: 0.12),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
