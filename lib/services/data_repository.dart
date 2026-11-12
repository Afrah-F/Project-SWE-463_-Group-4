import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/budget_category.dart';
import '../models/expense.dart';
import '../models/savings_goal.dart';
import '../utils/icon_registry.dart';

/// Everything the providers need from storage. Providers only talk to this
/// interface, so Phase 4 can add a `SqliteDataRepository` (sqflite, as approved
/// in Phase 2) and swap it in `main.dart` without touching any screen.
abstract class DataRepository {
  /// Returns null when the user has never had categories saved (first run).
  Future<List<BudgetCategory>?> loadCategories(String uid);
  Future<void> saveCategories(String uid, List<BudgetCategory> categories);

  Future<List<Expense>> loadExpenses(String uid);
  Future<void> saveExpenses(String uid, List<Expense> expenses);

  Future<SavingsGoal?> loadGoal(String uid);
  Future<void> saveGoal(String uid, SavingsGoal? goal);
}

/// The six default categories, totaling 3,050, as in the Phase 2 design.
List<BudgetCategory> defaultCategories(String uid) {
  BudgetCategory c(String id, double limit, String icon, int colorIndex) =>
      BudgetCategory(
        id: id,
        userId: uid,
        name: id,
        monthlyLimit: limit,
        iconKey: icon,
        colorValue: kCategoryColors[colorIndex],
        nameKey: 'cat_$id',
      );
  return [
    c('food', 800, 'food', 0),
    c('transport', 300, 'transport', 1),
    c('housing', 1500, 'housing', 2),
    c('subscriptions', 100, 'subscriptions', 3),
    c('course', 200, 'course', 4),
    c('other', 150, 'other', 5),
  ];
}

/// TEMPORARY storage for Phase 3: JSON in SharedPreferences, one key per user
/// and data type. It works on Android, iOS, desktop and Chrome with no setup.
/// Every record carries the owner's uid, so one user never sees another's data.
class LocalDataRepository implements DataRepository {
  final SharedPreferences _prefs;
  LocalDataRepository(this._prefs);

  String _k(String type, String uid) => 'mizania_${type}_$uid';

  @override
  Future<List<BudgetCategory>?> loadCategories(String uid) async {
    final raw = _prefs.getString(_k('categories', uid));
    if (raw == null) return null;
    return (jsonDecode(raw) as List)
        .map((e) => BudgetCategory.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> saveCategories(String uid, List<BudgetCategory> categories) =>
      _prefs.setString(_k('categories', uid),
          jsonEncode(categories.map((c) => c.toJson()).toList()));

  @override
  Future<List<Expense>> loadExpenses(String uid) async {
    final raw = _prefs.getString(_k('expenses', uid));
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Expense.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<void> saveExpenses(String uid, List<Expense> expenses) =>
      _prefs.setString(_k('expenses', uid),
          jsonEncode(expenses.map((e) => e.toJson()).toList()));

  @override
  Future<SavingsGoal?> loadGoal(String uid) async {
    final raw = _prefs.getString(_k('goal', uid));
    if (raw == null) return null;
    return SavingsGoal.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
  }

  @override
  Future<void> saveGoal(String uid, SavingsGoal? goal) async {
    if (goal == null) {
      await _prefs.remove(_k('goal', uid));
    } else {
      await _prefs.setString(_k('goal', uid), jsonEncode(goal.toJson()));
    }
  }
}
