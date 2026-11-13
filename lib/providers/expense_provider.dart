import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../services/data_repository.dart';
import '../services/recurring_service.dart';
import '../utils/formatters.dart';

class ExpenseProvider extends ChangeNotifier {
  final DataRepository _repo;
  ExpenseProvider(this._repo);

  static const Uuid _uuid = Uuid();

  String? _uid;
  List<Expense> _expenses = [];
  bool _loading = false;
  String? _errorKey;

  /// Newest first.
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get loading => _loading;
  String? get errorKey => _errorKey;
  bool get isEmpty => _expenses.isEmpty;

  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _expenses = [];
    _errorKey = null;
    if (uid == null) {
      _loading = false;
      return;
    }
    _loading = true;
    Future.microtask(load);
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    _loading = true;
    _errorKey = null;
    notifyListeners();
    try {
      var list = await _repo.loadExpenses(uid);
      // Create this month's copies of any "repeat every month" expense.
      final due = RecurringService.generateDue(list, DateTime.now());
      if (due.isNotEmpty) {
        list = [...list, ...due];
        await _repo.saveExpenses(uid, list);
      }
      if (_uid == uid) _expenses = _sorted(list);
    } catch (_) {
      _errorKey = 'err_load_failed';
    }
    _loading = false;
    notifyListeners();
  }

  List<Expense> _sorted(List<Expense> l) {
    final copy = [...l];
    copy.sort((a, b) => b.date.compareTo(a.date));
    return copy;
  }

  Future<void> _persist() async {
    final uid = _uid;
    if (uid != null) await _repo.saveExpenses(uid, _expenses);
  }

  Future<void> add({
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    bool isRecurring = false,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final cleanNote = (note == null || note.trim().isEmpty) ? null : note.trim();
    _expenses = _sorted([
      ..._expenses,
      Expense(
        id: _uuid.v4(),
        userId: uid,
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: cleanNote,
        isRecurring: isRecurring,
      ),
    ]);
    notifyListeners();
    await _persist();
  }

  Future<void> update(
    String id, {
    required double amount,
    required String categoryId,
    required DateTime date,
    String? note,
    required bool isRecurring,
  }) async {
    final cleanNote = (note == null || note.trim().isEmpty) ? null : note.trim();
    _expenses = _sorted(_expenses.map((e) {
      if (e.id != id) return e;
      return e.copyWith(
        amount: amount,
        categoryId: categoryId,
        date: date,
        note: cleanNote,
        clearNote: cleanNote == null,
        isRecurring: isRecurring,
      );
    }).toList());
    notifyListeners();
    await _persist();
  }

  Future<void> delete(String id) async {
    _expenses = _expenses.where((e) => e.id != id).toList();
    notifyListeners();
    await _persist();
  }

  /// Used after a category is deleted so its expenses are not orphaned.
  Future<void> reassignCategory(String fromId, String toId) async {
    _expenses = _expenses
        .map((e) => e.categoryId == fromId ? e.copyWith(categoryId: toId) : e)
        .toList();
    notifyListeners();
    await _persist();
  }

  // ---- Derived values used by Home, Budgets, Reports and Settings ----

  List<Expense> inMonth(DateTime month) =>
      _expenses.where((e) => isSameMonth(e.date, month)).toList();

  double totalSpent(DateTime month) =>
      inMonth(month).fold(0.0, (s, e) => s + e.amount);

  Map<String, double> spentByCategory(DateTime month) {
    final map = <String, double>{};
    for (final e in inMonth(month)) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
    }
    return map;
  }

  /// Total per calendar day of [month] (index 0 = day 1), for the bar chart.
  List<double> dailyTotals(DateTime month) {
    final days = daysInMonth(month.year, month.month);
    final totals = List<double>.filled(days, 0);
    for (final e in inMonth(month)) {
      totals[e.date.day - 1] += e.amount;
    }
    return totals;
  }
}
