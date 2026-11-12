import 'package:flutter/material.dart';

/// Arabic / English toggle used on "Set up your app" and in Settings.
class LanguageToggle extends StatelessWidget {
  final String languageCode;
  final ValueChanged<String> onChanged;

  const LanguageToggle({
    super.key,
    required this.languageCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<String>(value: 'ar', label: Text('العربية')),
          ButtonSegment<String>(value: 'en', label: Text('English')),
        ],
        selected: {languageCode},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}
