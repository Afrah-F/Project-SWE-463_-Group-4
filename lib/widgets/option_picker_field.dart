import 'package:flutter/material.dart';

/// A dropdown-style field that opens a bottom sheet list. It is used for the
/// currency choice instead of DropdownButtonFormField so it behaves the same
/// on every Flutter version.
class OptionPickerField extends StatelessWidget {
  final String label;
  final String valueLabel;
  final String sheetTitle;

  /// key -> label
  final Map<String, String> options;
  final String selectedKey;
  final ValueChanged<String> onChanged;

  const OptionPickerField({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.sheetTitle,
    required this.options,
    required this.selectedKey,
    required this.onChanged,
  });

  Future<void> _open(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(sheetTitle,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final e in options.entries)
                      ListTile(
                        title: Text(e.value),
                        trailing: e.key == selectedKey
                            ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                            : null,
                        onTap: () => Navigator.of(ctx).pop(e.key),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _open(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: Text(valueLabel),
      ),
    );
  }
}
