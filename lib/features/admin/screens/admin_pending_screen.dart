import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../models/startup_model.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/section_card.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../startups/providers/startup_provider.dart';

/// Deliberately minimal — one screen, no nav shell, per the "minimal admin
/// capability" scope agreed for this phase. Admin accounts are created by
/// manually setting `role: "admin"` on a user's Firestore doc via the
/// console; there's no self-serve admin signup.
class AdminPendingScreen extends ConsumerWidget {
  const AdminPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStartupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Verifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: pendingAsync.when(
        loading: () => const SkeletonList(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(pendingStartupsProvider),
        ),
        data: (startups) => startups.isEmpty
            ? const EmptyState(
                icon: Icons.task_alt_outlined,
                title: 'Nothing to review',
                message: 'New startup registrations will show up here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: startups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _PendingStartupCard(startup: startups[i]),
              ),
      ),
    );
  }
}

class _PendingStartupCard extends ConsumerStatefulWidget {
  const _PendingStartupCard({required this.startup});

  final StartupModel startup;

  @override
  ConsumerState<_PendingStartupCard> createState() => _PendingStartupCardState();
}

class _PendingStartupCardState extends ConsumerState<_PendingStartupCard> {
  bool _busy = false;

  Future<void> _decide(VerificationStatus status) async {
    setState(() => _busy = true);
    final success = await ref
        .read(startupControllerProvider.notifier)
        .setVerificationStatus(widget.startup.id, status);
    if (!mounted) return;
    if (success) {
      context.showSnack(
        status == VerificationStatus.verified
            ? '${widget.startup.name} approved.'
            : '${widget.startup.name} rejected.',
      );
    } else {
      context.showSnack('Could not update this startup. Please try again.', isError: true);
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProfileAvatar(
                photoUrl: widget.startup.logoUrl,
                name: widget.startup.name,
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.startup.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(widget.startup.industry,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(widget.startup.description, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Reject',
                  variant: ButtonVariant.outlined,
                  isLoading: _busy,
                  onPressed: () => _decide(VerificationStatus.rejected),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Approve',
                  isLoading: _busy,
                  onPressed: () => _decide(VerificationStatus.verified),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
