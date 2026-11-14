import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/category_progress_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/sign_out_dialog.dart';
import '../widgets/state_views.dart';

/// Left to spend, per-category progress and the five most recent expenses.
class HomeScreen extends StatelessWidget {
  /// Switches the shell to the Budgets tab ("Manage").
  final VoidCallback onManage;
  const HomeScreen({super.key, required this.onManage});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = context.watch<CategoryProvider>();
    final expenses = context.watch<ExpenseProvider>();

    Widget body;
    if (categories.loading || expenses.loading) {
      body = const LoadingView();
    } else if (categories.errorKey != null || expenses.errorKey != null) {
      body = ErrorView(
        messageKey: categories.errorKey ?? expenses.errorKey!,
        onRetry: () {
          categories.load();
          expenses.load();
        },
      );
    } else {
      body = _content(context, settings, categories, expenses);
    }

    return Scaffold(body: SafeArea(child: body));
  }

  Widget _content(BuildContext context, SettingsProvider settings,
      CategoryProvider categories, ExpenseProvider expenses) {
    final now = DateTime.now();
    final currency = settings.currencyCode;
    final planned = categories.totalLimit;
    final spent = expenses.totalSpent(now);
    final left = planned - spent;
    final progress = planned <= 0 ? 0.0 : (spent / planned).clamp(0.0, 1.0);
    final spentByCat = expenses.spentByCategory(now);
    final recent = expenses.expenses.take(5).toList();

    final userName = context.watch<AuthProvider>().user?.name ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ---- Greeting and sign out ----
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t('welcome_back'),
                      style: const TextStyle(
                          color: AppTheme.mutedText, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            IconButton(
              tooltip: context.t('sign_out'),
              icon: const Icon(Icons.logout),
              onPressed: () => confirmAndSignOut(context),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ---- Left to spend card ----
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatMonthYear(now, settings.languageCode).toUpperCase(),
                style: const TextStyle(
                    color: Colors.white70, fontSize: 11, letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              Text(context.t('left_to_spend'),
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 2),
              Text(
                formatMoney(left, currency),
                style: TextStyle(
                  color: left < 0 ? const Color(0xFFFFB4A9) : Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                      left < 0 ? const Color(0xFFFFB4A9) : Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${context.t('spent')} ${formatMoney(spent, currency)} ${context.t('of')} ${formatMoney(planned, currency)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/expense-form'),
          icon: const Icon(Icons.add),
          label: Text(context.t('add_expense')),
        ),
        const SizedBox(height: 22),

        // ---- Category budgets ----
        SectionHeader(
          title: context.t('category_budgets'),
          actionLabel: context.t('manage'),
          onAction: onManage,
        ),
        const SizedBox(height: 6),
        if (categories.categories.isEmpty)
          EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: context.t('no_categories_title'),
            message: context.t('no_categories_msg'),
            buttonLabel: context.t('add_category'),
            onPressed: () => Navigator.of(context).pushNamed('/category-form'),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                for (final c in categories.categories)
                  CategoryProgressTile(
                    category: c,
                    spent: spentByCat[c.id] ?? 0,
                    currencyCode: currency,
                  ),
              ],
            ),
          ),
        const SizedBox(height: 22),

        // ---- Recent ----
        SectionHeader(title: context.t('recent')),
        const SizedBox(height: 6),
        if (recent.isEmpty)
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: context.t('no_expenses_title'),
            message: context.t('no_expenses_home_msg'),
          )
        else
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              children: [
                for (final e in recent)
                  ExpenseTile(
                    expense: e,
                    category: categories.byId(e.categoryId),
                    currencyCode: currency,
                    languageCode: settings.languageCode,
                    onTap: () =>
                        Navigator.of(context).pushNamed('/expense-form', arguments: e),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
