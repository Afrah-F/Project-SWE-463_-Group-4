import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../models/expense.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_tile.dart';
import '../widgets/state_views.dart';

/// Browse, search and filter past expenses, grouped by day.
/// Tap a row to edit it, swipe it to delete.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String? _categoryId; // null = All

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<bool> _confirmDelete(BuildContext context, Expense e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.t('delete_expense_title')),
        content: Text(ctx.t('delete_expense_msg')),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(ctx.t('cancel'))),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(ctx.t('delete'),
                  style: const TextStyle(color: AppTheme.danger))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.rt('expense_deleted');
    await context.read<ExpenseProvider>().delete(e.id);
    messenger.showSnackBar(SnackBar(content: Text(msg)));
    // The provider already removed it, so tell Dismissible not to animate away
    // an item that is no longer in the list.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = context.watch<CategoryProvider>();
    final expenses = context.watch<ExpenseProvider>();

    Widget body;
    if (expenses.loading || categories.loading) {
      body = const LoadingView();
    } else if (expenses.errorKey != null) {
      body = ErrorView(messageKey: expenses.errorKey!, onRetry: expenses.load);
    } else {
      body = _content(context, settings, categories, expenses);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(context.t('all_expenses'),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed('/expense-form'),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(context.t('add')),
                  ),
                ],
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, SettingsProvider settings,
      CategoryProvider categories, ExpenseProvider expenses) {
    final q = _query.trim().toLowerCase();

    final filtered = expenses.expenses.where((e) {
      if (_categoryId != null && e.categoryId != _categoryId) return false;
      if (q.isEmpty) return true;
      final cat = categories.byId(e.categoryId);
      final catName = cat == null ? '' : context.categoryLabel(cat).toLowerCase();
      return (e.note ?? '').toLowerCase().contains(q) || catName.contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _search,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: context.t('search_hint'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  label: Text(context.t('all')),
                  selected: _categoryId == null,
                  onSelected: (_) => setState(() => _categoryId = null),
                ),
              ),
              for (final c in categories.categories)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(context.categoryLabel(c)),
                    selected: _categoryId == c.id,
                    onSelected: (_) => setState(() => _categoryId = c.id),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _list(context, settings, categories, expenses, filtered)),
      ],
    );
  }

  Widget _list(BuildContext context, SettingsProvider settings,
      CategoryProvider categories, ExpenseProvider expenses, List<Expense> filtered) {
    if (expenses.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: context.t('no_expenses_title'),
            message: context.t('no_expenses_history_msg'),
            buttonLabel: context.t('add_first_expense'),
            onPressed: () => Navigator.of(context).pushNamed('/expense-form'),
          ),
        ],
      );
    }
    if (filtered.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EmptyState(
            icon: Icons.search_off,
            title: context.t('no_matches_title'),
            message: context.t('no_matches_msg'),
          ),
        ],
      );
    }

    // Flatten into day headers + rows (the list is already newest first).
    final items = <Object>[];
    DateTime? lastDay;
    for (final e in filtered) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(e);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        if (item is DateTime) {
          return Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 4),
            child: Text(
              formatDayHeader(item, settings.languageCode),
              style: const TextStyle(
                  color: AppTheme.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          );
        }
        final e = item as Expense;
        return Dismissible(
          key: ValueKey(e.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(context, e),
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.danger,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          // A Material (not a colored Container) so the ListTile's ink and
          // background are painted on top of the card color.
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFFE6E9E4)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ExpenseTile(
                  expense: e,
                  category: categories.byId(e.categoryId),
                  currencyCode: settings.currencyCode,
                  languageCode: settings.languageCode,
                  onTap: () => Navigator.of(context)
                      .pushNamed('/expense-form', arguments: e),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
