import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// A labeled text field that turns each submitted value into a removable
/// chip — used for skills/interests/portfolio links wherever a student
/// builds up a short list of free-text entries.
class ChipInput extends StatefulWidget {
  const ChipInput({
    super.key,
    required this.label,
    required this.values,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final List<String> values;
  final ValueChanged<List<String>> onChanged;
  final String? hint;

  @override
  State<ChipInput> createState() => _ChipInputState();
}

class _ChipInputState extends State<ChipInput> {
  final _controller = TextEditingController();

  void _add(String raw) {
    final value = raw.trim();
    if (value.isEmpty || widget.values.contains(value)) return;
    widget.onChanged([...widget.values, value]);
    _controller.clear();
  }

  void _remove(String value) {
    widget.onChanged(widget.values.where((v) => v != value).toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          onSubmitted: _add,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Type and press enter to add',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _add(_controller.text),
            ),
          ),
        ),
        if (widget.values.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.values
                .map((v) => Chip(
                      label: Text(v),
                      backgroundColor: AppColors.primaryLight,
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () => _remove(v),
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
