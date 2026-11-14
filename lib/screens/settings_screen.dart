import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../providers/auth_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../services/csv_export_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/language_toggle.dart';
import '../widgets/option_picker_field.dart';
import '../widgets/sign_out_dialog.dart';

/// Currency, language, bill reminders, CSV export and sign out.
/// Change password lives under Edit Profile (the account card), not here.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _export(BuildContext context) async {
    final expenses = context.read<ExpenseProvider>().expenses;
    final categories = context.read<CategoryProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (expenses.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(context.rt('export_empty'))));
      return;
    }

    final csv = CsvExportService.build(
      expenses: expenses,
      categories: categories.byIdMap,
      categoryName: context.rCategoryLabel,
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.t('export_csv')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              csv,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(ctx.t('close'))),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            onPressed: () async {
              final msg = ctx.rt('csv_copied');
              await Clipboard.setData(ClipboardData(text: csv));
              if (ctx.mounted) Navigator.of(ctx).pop();
              messenger.showSnackBar(SnackBar(content: Text(msg)));
            },
            child: Text(ctx.t('copy')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final user = context.watch<AuthProvider>().user;
    final currencyOptions = {
      for (final e in kCurrencies.entries) e.key: '${e.key} - ${e.value}',
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(context.t('tab_settings'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),

            // Account
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDDE8E1),
                  child: Icon(Icons.person_outline, color: AppTheme.primary),
                ),
                title: Text(user?.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(user?.email ?? ''),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
              ),
            ),
            const SizedBox(height: 12),

            // Currency + language
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OptionPickerField(
                    label: context.t('currency'),
                    valueLabel:
                        currencyOptions[settings.currencyCode] ?? settings.currencyCode,
                    sheetTitle: context.t('currency'),
                    options: currencyOptions,
                    selectedKey: settings.currencyCode,
                    onChanged: settings.setCurrency,
                  ),
                  const SizedBox(height: 16),
                  Text(context.t('language'),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  LanguageToggle(
                    languageCode: settings.languageCode,
                    onChanged: settings.setLanguage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bill reminders
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SwitchListTile(
                title: Text(context.t('bill_reminders'),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(context.t('bill_reminders_hint'),
                    style: const TextStyle(fontSize: 12)),
                value: settings.billRemindersEnabled,
                onChanged: settings.setBillReminders,
              ),
            ),
            const SizedBox(height: 12),

            // Export
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.t('export_expenses'),
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(context.t('export_expenses_hint'),
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.mutedText)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _export(context),
                    icon: const Icon(Icons.download, size: 18),
                    label: Text(context.t('export_csv')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Links
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.danger),
                    title: Text(context.t('sign_out'),
                        style: const TextStyle(color: AppTheme.danger)),
                    onTap: () => confirmAndSignOut(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
