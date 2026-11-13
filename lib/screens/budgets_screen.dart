import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/category_progress_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/state_views.dart';

/// Review and manage the monthly limit of every category.
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = context.watch<CategoryProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final now = DateTime.now();
    final spentByCat = expenses.spentByCategory(now);

    Widget list;
    if (categories.loading) {
      list = const LoadingView();
    } else if (categories.errorKey != null) {
      list = ErrorView(messageKey: categories.errorKey!, onRetry: categories.load);
    } else if (categories.categories.isEmpty) {
      list = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: context.t('no_categories_title'),
            message: context.t('no_categories_msg'),
            buttonLabel: context.t('add_category'),
            onPressed: () => Navigator.of(context).pushNamed('/category-form'),
          ),
        ],
      );
    } else {
      list = ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final c in categories.categories)
                  CategoryProgressTile(
                    category: c,
                    spent: spentByCat[c.id] ?? 0,
                    currencyCode: settings.currencyCode,
                    showIcon: true,
                    onTap: () => Navigator.of(context)
                        .pushNamed('/category-form', arguments: c),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatMonthYear(now, settings.languageCode).toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              letterSpacing: 1.5,
                              color: AppTheme.mutedText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${formatMoney(categories.totalLimit, settings.currencyCode)} ${context.t('planned')}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed('/category-form'),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.t('category')),
                  ),
                ],
              ),
            ),
            Expanded(child: list),
          ],
        ),
      ),
    );
  }
}
