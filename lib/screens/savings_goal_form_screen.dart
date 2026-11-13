import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/validators.dart';

/// Set a savings goal (new) or edit the existing one.
///
/// [embedded] is true when the Savings tab shows this form because there is no
/// goal yet: saving then just makes the tab switch to the goal view.
class SavingsGoalFormScreen extends StatefulWidget {
  final SavingsGoal? goal;
  final bool embedded;
  const SavingsGoalFormScreen({super.key, this.goal, this.embedded = false});

  @override
  State<SavingsGoalFormScreen> createState() => _SavingsGoalFormScreenState();
}

class _SavingsGoalFormScreenState extends State<SavingsGoalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _target;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    _name = TextEditingController(text: g?.name ?? '');
    _target = TextEditingController(
        text: g == null ? '' : g.targetAmount.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final provider = context.read<SavingsProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final savedMsg = context.rt('goal_saved');
    final failMsg = context.rt('err_save_failed');
    try {
      await provider.saveGoal(
        name: _name.text,
        target: Validators.parseAmount(_target.text)!,
      );
      if (!widget.embedded) navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(savedMsg)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(failMsg)));
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsProvider>().currencyCode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: Text(context.t(widget.goal == null ? 'set_goal' : 'edit_goal')),
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
                  labelText: context.t('goal_name'),
                  hintText: context.t('goal_name_hint'),
                ),
                validator: (v) {
                  final k = Validators.required(v, key: 'err_name_required');
                  return k == null ? null : context.rt(k);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _target,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '${context.t('target_amount')} ($currency)',
                  hintText: '0.00',
                ),
                validator: (v) {
                  final k = Validators.positiveAmount(v);
                  return k == null ? null : context.rt(k);
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(context.t('save_goal')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
