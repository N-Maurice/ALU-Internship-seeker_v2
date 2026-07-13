import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/utilities/date_formatter.dart';
import '../../../models/opportunity_model.dart';
import '../../../providers/app_providers.dart';
import '../../authentication/providers/auth_provider.dart';

class OpportunityCard extends ConsumerWidget {
  const OpportunityCard({super.key, required this.opportunity});

  final OpportunityModel opportunity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).value;
    final isSaved = profile?.savedOpportunityIds.contains(opportunity.id) ?? false;

    return InkWell(
      onTap: () => context.push('/opportunities/${opportunity.id}'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    opportunity.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (profile != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: AppColors.navy),
                    onPressed: () => ref.read(userRepositoryProvider).setSavedOpportunity(
                          profile.uid,
                          opportunity.id,
                          !isSaved,
                        ),
                  ),
              ],
            ),
            Text(opportunity.startupName, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MetaItem(Icons.work_outline, opportunity.category)),
                Expanded(
                    child: _MetaItem(Icons.place_outlined, opportunity.location)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _MetaItem(Icons.schedule_outlined, opportunity.duration)),
                Expanded(
                  child: _MetaItem(
                    Icons.event_outlined,
                    'Posted ${DateFormatter.relative(opportunity.postedAt)}',
                  ),
                ),
              ],
            ),
            if (opportunity.requiredSkills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: opportunity.requiredSkills
                    .map((s) => Chip(
                          label: Text(s),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
