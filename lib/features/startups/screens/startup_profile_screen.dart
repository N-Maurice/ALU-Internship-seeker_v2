import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/startup_provider.dart';

class StartupProfileScreen extends ConsumerWidget {
  const StartupProfileScreen({super.key, required this.startupId});

  final String startupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(startupByIdProvider(startupId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Startup Profile'),
      ),
      body: startupAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(startupByIdProvider(startupId)),
        ),
        data: (startup) => startup == null
            ? const EmptyState(
                icon: Icons.business_outlined,
                title: 'Startup not found',
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ProfileAvatar(photoUrl: startup.logoUrl, name: startup.name, radius: 36),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          startup.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (startup.isVerified)
                        const Chip(
                          avatar: Icon(Icons.verified, size: 16, color: Colors.white),
                          label: Text('ALU Approved'),
                          backgroundColor: AppColors.navy,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(startup.industry,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  const Text('About',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(startup.description, style: const TextStyle(height: 1.6)),
                ],
              ),
      ),
    );
  }
}
