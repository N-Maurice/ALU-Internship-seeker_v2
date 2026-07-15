import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../../../models/startup_model.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/chip_input.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../startups/providers/startup_provider.dart';

const _suggestedSkills = ['Data Analysis', 'Python', 'UI Design'];

/// Handles both create and edit — `opportunityId == null` means create.
class OpportunityFormScreen extends ConsumerStatefulWidget {
  const OpportunityFormScreen({super.key, this.opportunityId});

  final String? opportunityId;

  @override
  ConsumerState<OpportunityFormScreen> createState() => _OpportunityFormScreenState();
}

class _OpportunityFormScreenState extends ConsumerState<OpportunityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _departmentController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  final _requiredSkills = <String>[];
  WorkMode _workMode = WorkMode.remote;
  DateTime? _deadline;
  bool _loadingExisting = false;
  bool _saving = false;

  bool get _isEditing => widget.opportunityId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadExisting();
  }

  Future<void> _loadExisting() async {
    setState(() => _loadingExisting = true);
    final opportunity =
        await ref.read(opportunityRepositoryProvider).getById(widget.opportunityId!);
    if (!mounted) return;
    if (opportunity != null) {
      _titleController.text = opportunity.title;
      _descriptionController.text = opportunity.description;
      _departmentController.text = opportunity.category;
      _durationController.text = opportunity.duration;
      _locationController.text = opportunity.location;
      _requiredSkills
        ..clear()
        ..addAll(opportunity.requiredSkills);
      _workMode = opportunity.workMode;
      _deadline = opportunity.deadline;
    }
    setState(() => _loadingExisting = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _addSuggestedSkill(String skill) {
    if (_requiredSkills.contains(skill)) return;
    setState(() => _requiredSkills.add(skill));
  }

  Future<void> _submit(OpportunityStatus targetStatus) async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) {
      context.showSnack('You appear to be signed out. Please sign in again.', isError: true);
      return;
    }

    setState(() => _saving = true);

    // `build()` keeps `myStartupProvider` actively watched for as long as
    // this screen is mounted (Riverpod pauses a StreamProvider's underlying
    // subscription when nothing is watching it, so a one-shot `ref.read`
    // here — with no active watcher elsewhere — could await a paused
    // stream that never delivers). By the time the user has filled in the
    // form and tapped submit, that watch has almost certainly already
    // resolved; `.future` below is just a short belt-and-suspenders wait
    // for the rare case it's still loading.
    final StartupModel? startup;
    try {
      startup = ref.read(myStartupProvider).value ??
          await ref.read(myStartupProvider.future).timeout(const Duration(seconds: 15));
    } catch (_) {
      if (mounted) {
        context.showSnack(
          'Could not load your startup — check your connection and try again.',
          isError: true,
        );
        setState(() => _saving = false);
      }
      return;
    }
    if (startup == null) {
      if (mounted) {
        context.showSnack('Could not find your startup. Please try again.', isError: true);
        setState(() => _saving = false);
      }
      return;
    }

    final controller = ref.read(opportunityControllerProvider.notifier);
    bool success;

    if (_isEditing) {
      success = await controller.update(widget.opportunityId!, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _departmentController.text.trim(),
        'requiredSkills': _requiredSkills,
        'duration': _durationController.text.trim(),
        'location': _locationController.text.trim(),
        'workMode': _workMode.name,
        'deadline': _deadline,
        'status': targetStatus.name,
      });
    } else {
      success = await controller.create(
        OpportunityModel(
          id: '',
          startupId: startup.id,
          startupName: startup.name,
          startupLogoUrl: startup.logoUrl,
          postedByUid: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _departmentController.text.trim(),
          requiredSkills: _requiredSkills,
          duration: _durationController.text.trim(),
          location: _locationController.text.trim(),
          workMode: _workMode,
          deadline: _deadline,
          postedAt: DateTime.now(),
          status: targetStatus,
        ),
      );
    }

    if (!mounted) return;
    if (success) {
      context.showSnack(
        targetStatus == OpportunityStatus.draft
            ? 'Saved as draft.'
            : (_isEditing ? 'Opportunity updated.' : 'Opportunity published!'),
      );
      context.pop();
    } else {
      context.showSnack('Something went wrong. Please try again.', isError: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Actively watching here (rather than only reading inside `_submit`)
    // keeps the provider's underlying Firestore subscription alive for the
    // whole time this screen is open, so it has resolved well before the
    // user taps Save/Publish — see the comment in `_submit` for why.
    final startupAsync = ref.watch(myStartupProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Opportunity' : 'Create New Opportunity')),
      body: SafeArea(
        child: _loadingExisting
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (startupAsync.value != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Posting for ${startupAsync.value!.name}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Text(
                        "Provide the details for the new role to connect with ALU's elite talent pool.",
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Job Title',
                        controller: _titleController,
                        hint: 'e.g. Software Engineer Intern',
                        icon: Icons.title,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a job title' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Department',
                        controller: _departmentController,
                        hint: 'e.g. Engineering, Growth, Product',
                        icon: Icons.category_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a department' : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Internship Type', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 8),
                      _WorkModeCard(
                        icon: Icons.public,
                        label: 'Remote',
                        selected: _workMode == WorkMode.remote,
                        onTap: () => setState(() => _workMode = WorkMode.remote),
                      ),
                      const SizedBox(height: 10),
                      _WorkModeCard(
                        icon: Icons.holiday_village_outlined,
                        label: 'Hybrid',
                        selected: _workMode == WorkMode.hybrid,
                        onTap: () => setState(() => _workMode = WorkMode.hybrid),
                      ),
                      const SizedBox(height: 10),
                      _WorkModeCard(
                        icon: Icons.location_on_outlined,
                        label: 'On-site',
                        selected: _workMode == WorkMode.onSite,
                        onTap: () => setState(() => _workMode = WorkMode.onSite),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Duration',
                        controller: _durationController,
                        hint: 'e.g. 3 Months, 6 Months',
                        icon: Icons.schedule_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a duration' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Location',
                        controller: _locationController,
                        hint: 'e.g. Kigali, Rwanda',
                        icon: Icons.place_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a location' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Role Description',
                        controller: _descriptionController,
                        hint: 'Describe the responsibilities, project scope, and expectations...',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
                      ),
                      const SizedBox(height: 16),
                      ChipInput(
                        label: 'Skills Required',
                        values: _requiredSkills,
                        hint: 'Add a skill and press Enter',
                        onChanged: (v) => setState(() {
                          _requiredSkills
                            ..clear()
                            ..addAll(v);
                        }),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          const Text('Suggested:',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          for (final skill in _suggestedSkills)
                            ActionChip(
                              label: Text(skill),
                              onPressed: () => _addSuggestedSkill(skill),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('Application Deadline (optional)',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: _pickDeadline,
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          _deadline == null
                              ? 'Select a deadline'
                              : DateFormat('MMM d, yyyy').format(_deadline!),
                        ),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        label: 'Save as Draft',
                        variant: ButtonVariant.outlined,
                        isLoading: _saving,
                        onPressed: () => _submit(OpportunityStatus.draft),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Publish Opportunity',
                        isLoading: _saving,
                        onPressed: () => _submit(OpportunityStatus.open),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _WorkModeCard extends StatelessWidget {
  const _WorkModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: selected ? AppColors.navy : AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.navy : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
