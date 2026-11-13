import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../models/budget_category.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_registry.dart';
import '../utils/validators.dart';

/// Add category / Edit category (pass a [BudgetCategory] to edit).
class CategoryFormScreen extends StatefulWidget {
  final BudgetCategory? category;
  const CategoryFormScreen({super.key, this.category});

  @override
  State<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends State<CategoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _limit;
  late String _iconKey;
  late int _colorValue;
  late final String _originalName; // what the user saw when the form opened
  bool _saving = false;

  bool get _isEdit => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _originalName = c == null ? '' : context.rCategoryLabel(c);
    _name = TextEditingController(text: _originalName);
    _limit = TextEditingController(
        text: c == null ? '' : c.monthlyLimit.toStringAsFixed(0));
    _iconKey = c?.iconKey ?? kCategoryIcons.keys.first;
    _colorValue = c?.colorValue ?? kCategoryColors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _limit.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<CategoryProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final savedMsg = context.rt('category_saved');
    final limit = Validators.parseAmount(_limit.text)!;

    try {
      if (_isEdit) {
        await provider.update(
          widget.category!.id,
          name: _name.text,
          nameChanged: _name.text.trim() != _originalName,
          monthlyLimit: limit,
          iconKey: _iconKey,
          colorValue: _colorValue,
        );
      } else {
        await provider.add(
          name: _name.text,
          monthlyLimit: limit,
          iconKey: _iconKey,
          colorValue: _colorValue,
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
        title: Text(ctx.t('delete_category_title')),
        content: Text(ctx.t('delete_category_msg')),
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

    final cats = context.read<CategoryProvider>();
    final expenses = context.read<ExpenseProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final msg = context.rt('category_deleted');
    final id = widget.category!.id;

    // Move this category's expenses to "Other" (or the first remaining one)
    // so no expense is left without a category.
    final remaining = cats.categories.where((c) => c.id != id).toList();
    BudgetCategory? target;
    for (final c in remaining) {
      if (c.id == 'other') target = c;
    }
    target ??= remaining.isEmpty ? null : remaining.first;
    if (target != null) await expenses.reassignCategory(id, target.id);
    await cats.delete(id);

    navigator.pop();
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().currencyCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t(_isEdit ? 'edit_category' : 'add_category')),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _name,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: context.t('name'),
                  hintText: context.t('category_name_hint'),
                ),
                validator: (v) {
                  final k = Validators.required(v, key: 'err_name_required');
                  return k == null ? null : context.rt(k);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _limit,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${context.t('monthly_limit')} ($currency)',
                  hintText: '0',
                ),
                validator: (v) {
                  final k = Validators.nonNegativeAmount(v);
                  return k == null ? null : context.rt(k);
                },
              ),
              const SizedBox(height: 20),
              Text(context.t('icon'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  for (final e in kCategoryIcons.entries)
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _iconKey = e.key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _iconKey == e.key
                              ? const Color(0xFFDDE8E1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _iconKey == e.key
                                ? AppTheme.primary
                                : const Color(0xFFE2E6DF),
                            width: _iconKey == e.key ? 1.6 : 1,
                          ),
                        ),
                        child: Icon(e.value, color: AppTheme.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Text(context.t('color'),
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final c in kCategoryColors)
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _colorValue = c),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _colorValue == c ? Colors.black87 : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: _colorValue == c
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 26),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(context.t('save_category')),
              ),
              if (_isEdit) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.t('delete')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
