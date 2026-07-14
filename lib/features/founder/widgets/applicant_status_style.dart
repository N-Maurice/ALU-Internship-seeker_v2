import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../models/application_model.dart';

/// Status badge color used across the founder's applicant screens, matching
/// the design spec's New=blue / Reviewing=amber / Interviewed=purple /
/// Accepted=green / Rejected=red badge coloring.
Color applicantStatusColor(ApplicationStatus status) => switch (status) {
      ApplicationStatus.submitted => Colors.blue,
      ApplicationStatus.underReview => AppColors.warning,
      ApplicationStatus.interview => Colors.purple,
      ApplicationStatus.accepted => AppColors.success,
      ApplicationStatus.rejected => AppColors.error,
    };
