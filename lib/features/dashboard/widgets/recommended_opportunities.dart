import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../../opportunities/widgets/opportunity_card.dart';

class RecommendedOpportunities extends StatelessWidget {
  const RecommendedOpportunities({super.key, required this.opportunities});

  final List<OpportunityModel> opportunities;

  @override
  Widget build(BuildContext context) {
    if (opportunities.isEmpty) {
      return const Text(
        'No open opportunities right now — check back soon.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < opportunities.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          OpportunityCard(opportunity: opportunities[i]),
        ],
      ],
    );
  }
}
