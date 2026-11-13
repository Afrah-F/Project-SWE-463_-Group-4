import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/savings_goal.dart';
import '../services/data_repository.dart';

class SavingsProvider extends ChangeNotifier {
  final DataRepository _repo;
  SavingsProvider(this._repo);

  static const Uuid _uuid = Uuid();

  String? _uid;
  SavingsGoal? _goal;
  bool _loading = false;
  String? _errorKey;

  SavingsGoal? get goal => _goal;
  bool get hasGoal => _goal != null;
  bool get loading => _loading;
  String? get errorKey => _errorKey;

  void setUser(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    _goal = null;
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
      final g = await _repo.loadGoal(uid);
      if (_uid == uid) _goal = g;
    } catch (_) {
      _errorKey = 'err_load_failed';
    }
    _loading = false;
    notifyListeners();
  }

  /// Creates the goal, or edits name/target while keeping the saved amount.
  Future<void> saveGoal({required String name, required double target}) async {
    final uid = _uid;
    if (uid == null) return;
    final current = _goal;
    _goal = current == null
        ? SavingsGoal(id: _uuid.v4(), userId: uid, name: name.trim(), targetAmount: target)
        : current.copyWith(name: name.trim(), targetAmount: target);
    notifyListeners();
    await _repo.saveGoal(uid, _goal);
  }

  Future<void> deposit(double amount) async {
    final uid = _uid;
    final current = _goal;
    if (uid == null || current == null) return;
    _goal = current.copyWith(savedAmount: current.savedAmount + amount);
    notifyListeners();
    await _repo.saveGoal(uid, _goal);
  }
}
