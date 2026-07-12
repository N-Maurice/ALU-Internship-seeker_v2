import 'package:flutter/material.dart';
import 'package:alu_internship_seeker_ii/models/opportunity_model.dart';

class OpportunityCard extends StatelessWidget {
  const OpportunityCard({super.key, required this.opportunity});

  final OpportunityModel opportunity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(opportunity.title,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(opportunity.company),
            const SizedBox(height: 12),
            Text(opportunity.description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 4),
                Expanded(child: Text(opportunity.location)),
                Chip(label: Text(opportunity.workType)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
