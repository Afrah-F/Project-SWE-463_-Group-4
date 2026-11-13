import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/budget_category.dart';
import '../services/data_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final DataRepository _repo;
  CategoryProvider(this._repo);

  static const Uuid _uuid = Uuid();

  String? _uid;
  List<BudgetCategory> _categories = [];
  bool _loading = false;
  String? _errorKey;

  List<BudgetCategory> get categories => List.unmodifiable(_categories);
  bool get loading => _loading;
  String? get errorKey => _errorKey;
  double get totalLimit => _categories.fold(0.0, (s, c) => s + c.monthlyLimit);

  BudgetCategory? byId(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  Map<String, BudgetCategory> get byIdMap => {for (final c in _categories) c.id: c};

  /// Called by the ProxyProvider whenever the signed-in user changes.
  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _categories = [];
    _errorKey = null;
    if (uid == null) {
      _loading = false;
      return;
    }
    _loading = true;
    // Defer so we never notify listeners in the middle of a build.
    Future.microtask(load);
  }

  Future<void> load() async {
    final uid = _uid;
    if (uid == null) return;
    _loading = true;
    _errorKey = null;
    notifyListeners();
    try {
      var list = await _repo.loadCategories(uid);
      if (list == null) {
        // First sign-in for this account: seed the six default categories.
        list = defaultCategories(uid);
        await _repo.saveCategories(uid, list);
      }
      if (_uid == uid) _categories = list;
    } catch (_) {
      _errorKey = 'err_load_failed';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> add({
    required String name,
    required double monthlyLimit,
    required String iconKey,
    required int colorValue,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    _categories = [
      ..._categories,
      BudgetCategory(
        id: _uuid.v4(),
        userId: uid,
        name: name.trim(),
        monthlyLimit: monthlyLimit,
        iconKey: iconKey,
        colorValue: colorValue,
      ),
    ];
    notifyListeners();
    await _repo.saveCategories(uid, _categories);
  }

  /// [nameChanged] is true only when the user typed a different name. A seeded
  /// category keeps its translated name (nameKey) until it is renamed.
  Future<void> update(
    String id, {
    required String name,
    required bool nameChanged,
    required double monthlyLimit,
    required String iconKey,
    required int colorValue,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    _categories = _categories.map((c) {
      if (c.id != id) return c;
      return c.copyWith(
        name: nameChanged ? name.trim() : c.name,
        monthlyLimit: monthlyLimit,
        iconKey: iconKey,
        colorValue: colorValue,
        clearNameKey: nameChanged,
      );
    }).toList();
    notifyListeners();
    await _repo.saveCategories(uid, _categories);
  }

  Future<void> delete(String id) async {
    final uid = _uid;
    if (uid == null) return;
    _categories = _categories.where((c) => c.id != id).toList();
    notifyListeners();
    await _repo.saveCategories(uid, _categories);
  }
}
