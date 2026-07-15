import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../providers/application_provider.dart';

/// A full screen rather than a dialog — a cover letter deserves real space.
/// This screen is itself the confirmation step; submitting here applies
/// directly, no extra dialog on top.
class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({super.key, required this.opportunityId});

  final String opportunityId;

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _coverLetterController = TextEditingController();

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opportunityAsync = ref.watch(opportunityByIdProvider(widget.opportunityId));
    final applying = ref.watch(applicationControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: SafeArea(
        child: opportunityAsync.when(
          loading: () => const LoadingWidget(),
          error: (error, _) => ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(opportunityByIdProvider(widget.opportunityId)),
          ),
          data: (opportunity) {
            if (opportunity == null) {
              return const EmptyState(
                icon: Icons.search_off,
                title: 'Opportunity not found',
                message: 'This listing may have been closed or removed.',
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(opportunity.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(opportunity.startupName,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text(
                    'Your profile skills and portfolio links will be shared automatically. '
                    'Adding a cover letter is optional but helps you stand out.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Cover Letter (optional)',
                    controller: _coverLetterController,
                    hint: "Tell ${opportunity.startupName} why you're a great fit...",
                    maxLines: 8,
                  ),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: 'Submit Application',
                    isLoading: applying,
                    onPressed: () async {
                      final success = await ref
                          .read(applicationControllerProvider.notifier)
                          .apply(opportunity, coverLetter: _coverLetterController.text);
                      if (!context.mounted) return;
                      if (success) {
                        context.showSnack('Application submitted to ${opportunity.startupName}!');
                        context.pop();
                      } else {
                        context.showSnack(
                          ref.read(applicationControllerProvider).error.toString(),
                          isError: true,
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
