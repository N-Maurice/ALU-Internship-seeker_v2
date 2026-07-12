import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../providers/opportunity_provider.dart';

class OpportunityFilterBar extends ConsumerWidget {
  const OpportunityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(opportunityFilterProvider);
    final notifier = ref.read(opportunityFilterProvider.notifier);

    final options = <String, WorkMode?>{
      'All': null,
      for (final mode in WorkMode.values) mode.label: mode,
    };

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = options.keys.elementAt(index);
          final mode = options[label];
          final selected = filter.workMode == mode;
          return ChoiceChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) => notifier.setWorkMode(mode),
            selectedColor: AppColors.navy,
            labelStyle: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.border),
          );
        },
      ),
    );
  }
}
