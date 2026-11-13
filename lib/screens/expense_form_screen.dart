import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../models/expense.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/icon_registry.dart';
import '../utils/validators.dart';
import '../widgets/amount_field.dart';
import '../widgets/app_card.dart';
import '../widgets/empty_state.dart';

/// Add expense / Edit expense (pass an [Expense] as the route argument to edit).
/// Flow: input -> validation -> ExpenseProvider (state + storage) -> back to the
/// previous screen, where the new expense is already visible.
class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  const ExpenseFormScreen({super.key, this.expense});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amount;
  late final TextEditingController _note;
  String? _categoryId;
  late DateTime _date;
  bool _repeat = false;
  bool _categoryError = false;
  bool _saving = false;

  bool get _isEdit => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final e = widget.expense;
    _amount = TextEditingController(text: e == null ? '' : e.amount.toStringAsFixed(2));
    _note = TextEditingController(text: e?.note ?? '');
    _categoryId = e?.categoryId;
    _date = e?.date ?? DateTime.now();
    _repeat = e?.isRecurring ?? false;
    if (e == null) {
      // Preselect the first category like the Phase 2 design.
      final cats = context.read<CategoryProvider>().categories;
      if (cats.isNotEmpty) _categoryId = cats.first.id;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final valid = _formKey.currentState!.validate();
    final catMissing = _categoryId == null;
    setState(() => _categoryError = catMissing);
    if (!valid || catMissing) return;

    setState(() => _saving = true);
    final provider = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final savedMsg = context.rt('expense_saved');
    final amount = Validators.parseAmount(_amount.text)!;

    try {
      if (_isEdit) {
        await provider.update(
          widget.expense!.id,
          amount: amount,
          categoryId: _categoryId!,
          date: _date,
          note: _note.text,
          isRecurring: _repeat,
        );
      } else {
        await provider.add(
          amount: amount,
          categoryId: _categoryId!,
          date: _date,
          note: _note.text,
          isRecurring: _repeat,
        );
      }
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(savedMsg)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(context.rt('err_save_failed'))));
    }
  }

  Future<void> _delete() async {
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
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final msg = context.rt('expense_deleted');
    await context.read<ExpenseProvider>().delete(widget.expense!.id);
    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(_isEdit ? 'edit_expense' : 'add_expense')),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: context.t('delete'),
              icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
              onPressed: _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: categories.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  EmptyState(
                    icon: Icons.category_outlined,
                    title: context.t('no_categories_title'),
                    message: context.t('no_categories_msg'),
                    buttonLabel: context.t('add_category'),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/category-form'),
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    AppCard(
                      child: AmountField(
                        controller: _amount,
                        currencyCode: settings.currencyCode,
                        autofocus: !_isEdit,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(context.t('category'),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in categories)
                          ChoiceChip(
                            avatar: Icon(iconForKey(c.iconKey),
                                size: 18, color: Color(c.colorValue)),
                            label: Text(context.categoryLabel(c)),
                            selected: _categoryId == c.id,
                            onSelected: (_) => setState(() {
                              _categoryId = c.id;
                              _categoryError = false;
                            }),
                          ),
                      ],
                    ),
                    if (_categoryError)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(context.t('err_choose_category'),
                            style: const TextStyle(
                                color: AppTheme.danger, fontSize: 12)),
                      ),
                    const SizedBox(height: 18),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: context.t('date'),
                          suffixIcon: const Icon(Icons.calendar_today, size: 18),
                        ),
                        child: Text(formatShortDate(_date, settings.languageCode)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _note,
                      maxLength: 80,
                      decoration: InputDecoration(
                        labelText: context.t('note_optional'),
                        hintText: context.t('note_hint'),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        title: Text(context.t('repeat_monthly'),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(context.t('repeat_monthly_hint'),
                            style: const TextStyle(fontSize: 12)),
                        value: _repeat,
                        onChanged: (v) => setState(() => _repeat = v),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text(context.t('save_expense')),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
