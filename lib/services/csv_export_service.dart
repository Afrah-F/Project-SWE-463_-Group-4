import '../models/budget_category.dart';
import '../models/expense.dart';

/// Builds the CSV text for "Export CSV". Phase 3 shows it in a dialog and
/// copies it to the clipboard; saving a file / share sheet is planned for Phase 4.
class CsvExportService {
  static String build({
    required List<Expense> expenses,
    required Map<String, BudgetCategory> categories,
    required String Function(BudgetCategory) categoryName,
  }) {
    final rows = <String>['date,category,amount,note,recurring'];
    final sorted = [...expenses]..sort((a, b) => a.date.compareTo(b.date));
    for (final e in sorted) {
      final cat = categories[e.categoryId];
      final d = e.date;
      final date =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      rows.add([
        date,
        _escape(cat == null ? '' : categoryName(cat)),
        e.amount.toStringAsFixed(2),
        _escape(e.note ?? ''),
        (e.isRecurring || e.recurringSourceId != null) ? 'yes' : 'no',
      ].join(','));
    }
    return rows.join('\n');
  }

  static String _escape(String v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}
