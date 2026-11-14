import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../models/budget_category.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/category_icon_badge.dart';
import '../widgets/empty_state.dart';
import '../widgets/state_views.dart';

/// Monthly spending summary: pie chart by category and bars by week.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _month = monthOf(DateTime.now());

  void _shift(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final categories = context.watch<CategoryProvider>();
    final expenses = context.watch<ExpenseProvider>();
    final canGoNext = _month.isBefore(monthOf(DateTime.now()));

    Widget body;
    if (expenses.loading || categories.loading) {
      body = const LoadingView();
    } else if (expenses.errorKey != null) {
      body = ErrorView(messageKey: expenses.errorKey!, onRetry: expenses.load);
    } else {
      final total = expenses.totalSpent(_month);
      body = total <= 0
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EmptyState(
                  icon: Icons.pie_chart_outline,
                  title: context.t('nothing_logged_title'),
                  message: context.t('nothing_logged_msg'),
                ),
              ],
            )
          : _charts(context, settings, categories, expenses, total);
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
                    child: Text(context.t('monthly_summary'),
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            // Month switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _shift(-1),
                    ),
                    Expanded(
                      child: Text(
                        formatMonthYear(_month, settings.languageCode),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: canGoNext ? () => _shift(1) : null,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _charts(BuildContext context, SettingsProvider settings,
      CategoryProvider categories, ExpenseProvider expenses, double total) {
    final currency = settings.currencyCode;
    final byCat = expenses.spentByCategory(_month);

    // Largest first.
    final entries = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    BudgetCategory? cat(String id) => categories.byId(id);

    final sections = <PieChartSectionData>[];
    for (final e in entries) {
      final c = cat(e.key);
      final pct = e.value / total * 100;
      sections.add(PieChartSectionData(
        value: e.value,
        color: Color(c?.colorValue ?? 0xFF8A8F8C),
        radius: 54,
        title: pct >= 8 ? '${pct.round()}%' : '',
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ));
    }

    // Weekly totals: days 1-7, 8-14, ...
    final daily = expenses.dailyTotals(_month);
    final weekCount = (daily.length / 7).ceil();
    final weekly = List<double>.filled(weekCount, 0);
    for (var i = 0; i < daily.length; i++) {
      weekly[i ~/ 7] += daily[i];
    }
    final maxWeek = weekly.fold(0.0, (m, v) => v > m ? v : m);
    // Resolved here (inside build) because the chart calls its title builder later.
    final weekLabel = context.t('week_short');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t('total_spent'),
                  style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
              Text(formatMoney(total, currency),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t('by_category'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 14),
              SizedBox(
                height: 190,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 44,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      CategoryIconBadge(category: cat(e.key), size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cat(e.key) == null
                              ? context.t('uncategorized')
                              : context.categoryLabel(cat(e.key)!),
                        ),
                      ),
                      Text(formatMoney(e.value, currency),
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t('by_week'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 18),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    maxY: maxWeek <= 0 ? 1 : maxWeek * 1.2,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '$weekLabel${value.toInt() + 1}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.mutedText),
                            ),
                          ),
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < weekly.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: weekly[i],
                              color: AppTheme.primary,
                              width: 22,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
