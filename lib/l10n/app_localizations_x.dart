import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/budget_category.dart';
import '../providers/settings_provider.dart';
import 'app_strings.dart';

extension TranslateX on BuildContext {
  /// Translate inside `build` (rebuilds the widget when the language changes).
  String t(String key) =>
      AppStrings.get(select<SettingsProvider, String>((s) => s.languageCode), key);

  /// Translate inside callbacks (button handlers, after an `await`).
  String rt(String key) =>
      AppStrings.get(read<SettingsProvider>().languageCode, key);

  /// Category name in the current language (seeded categories are translated,
  /// user-created or renamed ones show exactly what the user typed).
  String categoryLabel(BudgetCategory c) =>
      c.nameKey == null ? c.name : t(c.nameKey!);

  /// Same as [categoryLabel] for callbacks.
  String rCategoryLabel(BudgetCategory c) =>
      c.nameKey == null ? c.name : rt(c.nameKey!);
}
