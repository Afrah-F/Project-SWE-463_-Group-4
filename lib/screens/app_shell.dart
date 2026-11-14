import 'package:flutter/material.dart';

import '../l10n/app_localizations_x.dart';
import 'budgets_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'reports_screen.dart';
import 'savings_screen.dart';
import 'settings_screen.dart';

/// One Scaffold with the six-tab NavigationBar. IndexedStack keeps each tab's
/// state (scroll position, search text, selected month) when switching tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const int budgetsTab = 2;
  int _index = 0;

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onManage: () => _goTo(budgetsTab)),
      const HistoryScreen(),
      const BudgetsScreen(),
      const SavingsScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.t('tab_home')),
          NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long),
              label: context.t('tab_history')),
          NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet),
              label: context.t('tab_budgets')),
          NavigationDestination(
              icon: const Icon(Icons.monetization_on_outlined),
              selectedIcon: const Icon(Icons.monetization_on),
              label: context.t('tab_savings')),
          NavigationDestination(
              icon: const Icon(Icons.pie_chart_outline),
              selectedIcon: const Icon(Icons.pie_chart),
              label: context.t('tab_reports')),
          NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.t('tab_settings')),
        ],
      ),
    );
  }
}
