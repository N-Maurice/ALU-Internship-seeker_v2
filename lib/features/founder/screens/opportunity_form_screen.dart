import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/colors.dart';
import '../../../models/opportunity_model.dart';
import '../../../providers/app_providers.dart';
import '../../../shared/components/custom_button.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/chip_input.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../opportunities/providers/opportunity_provider.dart';
import '../../startups/providers/startup_provider.dart';

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
  final _categoryController = TextEditingController();
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
      _categoryController.text = opportunity.category;
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
    _categoryController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final controller = ref.read(opportunityControllerProvider.notifier);
    bool success;

    if (_isEditing) {
      success = await controller.update(widget.opportunityId!, {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        'requiredSkills': _requiredSkills,
        'duration': _durationController.text.trim(),
        'location': _locationController.text.trim(),
        'workMode': _workMode.name,
        'deadline': _deadline,
      });
    } else {
      final user = ref.read(authStateChangesProvider).value;
      final startup = ref.read(myStartupProvider).value;
      if (user == null || startup == null || !startup.isVerified) {
        if (mounted) {
          context.showSnack('Your startup must be approved before you can post.',
              isError: true);
          setState(() => _saving = false);
        }
        return;
      }
      success = await controller.create(
        OpportunityModel(
          id: '',
          startupId: startup.id,
          startupName: startup.name,
          startupLogoUrl: startup.logoUrl,
          postedByUid: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _categoryController.text.trim(),
          requiredSkills: _requiredSkills,
          duration: _durationController.text.trim(),
          location: _locationController.text.trim(),
          workMode: _workMode,
          deadline: _deadline,
          postedAt: DateTime.now(),
        ),
      );
    }

    if (!mounted) return;
    if (success) {
      context.showSnack(_isEditing ? 'Opportunity updated.' : 'Opportunity posted!');
      context.pop();
    } else {
      context.showSnack('Something went wrong. Please try again.', isError: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Opportunity' : 'Post an Opportunity')),
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
                      CustomTextField(
                        label: 'Title',
                        controller: _titleController,
                        hint: 'e.g. Product Design Fellow',
                        icon: Icons.title,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Description',
                        controller: _descriptionController,
                        hint: 'What will they be doing?',
                        icon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a description' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Category',
                        controller: _categoryController,
                        hint: 'e.g. Product Team, Engineering',
                        icon: Icons.category_outlined,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a category' : null,
                      ),
                      const SizedBox(height: 16),
                      ChipInput(
                        label: 'Required Skills',
                        values: _requiredSkills,
                        hint: 'e.g. Figma, User Research',
                        onChanged: (v) => setState(() {
                          _requiredSkills
                            ..clear()
                            ..addAll(v);
                        }),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Duration',
                        controller: _durationController,
                        hint: 'e.g. 3 Months',
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
                      Text('Work Mode', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<WorkMode>(
                        initialValue: _workMode,
                        decoration:
                            const InputDecoration(prefixIcon: Icon(Icons.business_center_outlined)),
                        items: WorkMode.values
                            .map((m) => DropdownMenuItem(value: m, child: Text(m.label)))
                            .toList(),
                        onChanged: (v) => setState(() => _workMode = v ?? _workMode),
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
                        label: _isEditing ? 'Save Changes' : 'Post Opportunity',
                        isLoading: _saving,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
