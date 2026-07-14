import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../models/startup_model.dart';
import '../../../shared/widgets/section_card.dart';

/// Explains why posting is disabled while a startup isn't verified yet —
/// shown on both the founder dashboard and My Opportunities, since an
/// unverified founder shouldn't be able to reach the opportunity form at
/// all rather than reaching it and finding it disabled there.
class VerificationBanner extends StatelessWidget {
  const VerificationBanner({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final isRejected = status == VerificationStatus.rejected;
    return SectionCard(
      child: Row(
        children: [
          Icon(
            isRejected ? Icons.cancel_outlined : Icons.hourglass_top_outlined,
            color: AppColors.warning,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isRejected
                  ? 'Your startup was not approved. Check your Startup Profile for details.'
                  : "Your startup is pending admin approval. You'll be able to post once it's approved.",
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
