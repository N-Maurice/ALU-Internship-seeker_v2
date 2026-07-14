import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../models/startup_model.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/components/profile_avatar.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../startups/providers/startup_provider.dart';

class FounderStartupScreen extends ConsumerWidget {
  const FounderStartupScreen({super.key});

  Color _statusColor(VerificationStatus status) => switch (status) {
        VerificationStatus.verified => AppColors.success,
        VerificationStatus.pending => AppColors.warning,
        VerificationStatus.rejected => AppColors.error,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(myStartupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Startup')),
      body: startupAsync.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(myStartupProvider),
        ),
        data: (startup) => startup == null
            ? const EmptyState(icon: Icons.business_outlined, title: 'No startup found')
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  ProfileAvatar(photoUrl: startup.logoUrl, name: startup.name, radius: 36),
                  const SizedBox(height: 16),
                  Text(startup.name,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Chip(
                    avatar: Icon(
                      startup.verificationStatus == VerificationStatus.verified
                          ? Icons.verified
                          : startup.verificationStatus == VerificationStatus.rejected
                              ? Icons.cancel
                              : Icons.hourglass_top,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: Text(startup.verificationStatus.label),
                    backgroundColor: _statusColor(startup.verificationStatus),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(startup.industry,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  const Text('About',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(startup.description, style: const TextStyle(height: 1.6)),
                  const SizedBox(height: 28),
                  CustomButton(
                    label: 'Edit Startup Details',
                    variant: ButtonVariant.outlined,
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => _EditStartupSheet(startup: startup),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EditStartupSheet extends ConsumerStatefulWidget {
  const _EditStartupSheet({required this.startup});

  final StartupModel startup;

  @override
  ConsumerState<_EditStartupSheet> createState() => _EditStartupSheetState();
}

class _EditStartupSheetState extends ConsumerState<_EditStartupSheet> {
  late final _nameController = TextEditingController(text: widget.startup.name);
  late final _industryController = TextEditingController(text: widget.startup.industry);
  late final _descriptionController = TextEditingController(text: widget.startup.description);
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success = await ref.read(startupControllerProvider.notifier).update(
      widget.startup.id,
      {
        'name': _nameController.text.trim(),
        'industry': _industryController.text.trim(),
        'description': _descriptionController.text.trim(),
      },
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      context.showSnack('Could not save changes.', isError: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Edit Startup Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            CustomTextField(label: 'Startup Name', controller: _nameController),
            const SizedBox(height: 12),
            CustomTextField(label: 'Industry', controller: _industryController),
            const SizedBox(height: 12),
            CustomTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            CustomButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
