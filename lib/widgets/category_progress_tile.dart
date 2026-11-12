import 'package:flutter/material.dart';

import '../l10n/app_localizations_x.dart';
import '../models/budget_category.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'category_icon_badge.dart';

/// One category with "spent of limit" and a progress bar. Used by Home
/// (compact) and Budgets (with icon and chevron).
class CategoryProgressTile extends StatelessWidget {
  final BudgetCategory category;
  final double spent;
  final String currencyCode;
  final bool showIcon;
  final VoidCallback? onTap;

  const CategoryProgressTile({
    super.key,
    required this.category,
    required this.spent,
    required this.currencyCode,
    this.showIcon = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final limit = category.monthlyLimit;
    final over = limit > 0 ? spent > limit : spent > 0;
    final progress = limit <= 0 ? (spent > 0 ? 1.0 : 0.0) : (spent / limit).clamp(0.0, 1.0);
    final barColor = over ? AppTheme.danger : Color(category.colorValue);
    final label =
        '${formatMoney(spent, currencyCode)} ${context.t('of')} ${formatMoney(limit, currencyCode)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (showIcon) ...[
              CategoryIconBadge(category: category),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.categoryLabel(category),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (!showIcon)
                        Text(label,
                            style: TextStyle(
                              fontSize: 12,
                              color: over ? AppTheme.danger : AppTheme.mutedText,
                            )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFEAEDE8),
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    ),
                  ),
                  if (showIcon) ...[
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                          fontSize: 12,
                          color: over ? AppTheme.danger : AppTheme.mutedText,
                        )),
                  ],
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.mutedText),
            ],
          ],
        ),
      ),
    );
  }
}
