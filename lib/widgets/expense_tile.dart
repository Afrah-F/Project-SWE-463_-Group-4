import 'package:flutter/material.dart';

import '../l10n/app_localizations_x.dart';
import '../models/budget_category.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'category_icon_badge.dart';

/// One expense row used by Home (Recent) and History.
class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final BudgetCategory? category;
  final String currencyCode;
  final String languageCode;
  final VoidCallback? onTap;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
    required this.currencyCode,
    required this.languageCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catName =
        category == null ? context.t('uncategorized') : context.categoryLabel(category!);
    final hasNote = expense.note != null && expense.note!.isNotEmpty;
    final repeats = expense.isRecurring || expense.recurringSourceId != null;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CategoryIconBadge(category: category),
      title: Text(hasNote ? expense.note! : catName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              hasNote
                  ? '$catName · ${formatShortDate(expense.date, languageCode)}'
                  : formatShortDate(expense.date, languageCode),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppTheme.mutedText),
            ),
          ),
          if (repeats) ...[
            const SizedBox(width: 6),
            const Icon(Icons.repeat, size: 13, color: AppTheme.mutedText),
          ],
        ],
      ),
      trailing: Text(
        formatMoney(expense.amount, currencyCode),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}
