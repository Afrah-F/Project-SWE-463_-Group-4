import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../models/savings_goal.dart';
import '../providers/savings_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/amount_field.dart';
import '../widgets/app_card.dart';
import '../widgets/state_views.dart';
import 'savings_goal_form_screen.dart';

/// Savings tab. No goal yet: shows "Set a savings goal". With a goal: shows the
/// progress ring and the deposit field.
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final savings = context.watch<SavingsProvider>();

    if (savings.loading) {
      return const Scaffold(body: SafeArea(child: LoadingView()));
    }
    if (savings.errorKey != null) {
      return Scaffold(
        body: SafeArea(
            child: ErrorView(messageKey: savings.errorKey!, onRetry: savings.load)),
      );
    }
    if (!savings.hasGoal) {
      return const SavingsGoalFormScreen(embedded: true);
    }
    return _GoalView(goal: savings.goal!);
  }
}

class _GoalView extends StatefulWidget {
  final SavingsGoal goal;
  const _GoalView({required this.goal});

  @override
  State<_GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<_GoalView> {
  final _formKey = GlobalKey<FormState>();
  final _deposit = TextEditingController();

  @override
  void dispose() {
    _deposit.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = Validators.parseAmount(_deposit.text)!;
    final provider = context.read<SavingsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.rt('deposit_added');
    await provider.deposit(amount);
    _deposit.clear();
    _formKey.currentState?.reset();
    FocusManager.instance.primaryFocus?.unfocus();
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final goal = widget.goal;
    final currency = settings.currencyCode;
    final percent = (goal.progress * 100).floor();
    final reached = goal.savedAmount >= goal.targetAmount;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              child: Text(goal.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(
                    width: 190,
                    height: 190,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 190,
                          height: 190,
                          child: CircularProgressIndicator(
                            value: goal.progress,
                            strokeWidth: 16,
                            backgroundColor: const Color(0xFFEAEDE8),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$percent%',
                                style: const TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.w800)),
                            Text(context.t('saved'),
                                style: const TextStyle(color: AppTheme.mutedText)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(context.t('saved'),
                      style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                  Text(formatMoney(goal.savedAmount, currency),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(context.t('still_to_go'),
                      style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                  Text(formatMoney(goal.remaining, currency),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  if (reached) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.celebration, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        Text(context.t('goal_reached'),
                            style: const TextStyle(
                                color: AppTheme.primary, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed('/savings-goal-form', arguments: goal),
                    child: Text(context.t('edit_goal')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Form(
                key: _formKey,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AmountField(
                        controller: _deposit,
                        currencyCode: currency,
                        labelKey: 'add_to_savings',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _add,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(context.t('add')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
