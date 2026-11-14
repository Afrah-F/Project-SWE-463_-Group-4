import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthMode { signIn, signUp }

/// Owns the signed-in user, the loading flag and the last error. The first
/// screen shown at launch (see AuthGate in app.dart) depends on this provider.
class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  AuthProvider(this._service);

  AppUser? _user;
  bool _initializing = true;
  bool _loading = false;
  String? _errorKey;
  AuthMode _mode = AuthMode.signIn;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get initializing => _initializing;
  bool get loading => _loading;

  /// Translation key of the last error, or null.
  String? get errorKey => _errorKey;
  AuthMode get mode => _mode;

  /// Called once at startup: restores the previous session if there is one.
  Future<void> init() async {
    try {
      _user = await _service.restoreSession();
    } catch (_) {
      _user = null;
    }
    _initializing = false;
    notifyListeners();
  }

  void showSignUp() {
    _mode = AuthMode.signUp;
    _errorKey = null;
    notifyListeners();
  }

  void showSignIn() {
    _mode = AuthMode.signIn;
    _errorKey = null;
    notifyListeners();
  }

  void clearError() {
    if (_errorKey == null) return;
    _errorKey = null;
    notifyListeners();
  }

  Future<bool> signUp(String name, String email, String password) =>
      _run(() async => _user = await _service.signUp(name, email, password));

  Future<bool> signIn(String email, String password) =>
      _run(() async => _user = await _service.signIn(email, password));

  Future<bool> updateProfile(String name, String email) => _run(() async {
        _user = await _service.updateProfile(_user!.uid, name, email);
      });

  Future<bool> changePassword(String current, String next) =>
      _run(() => _service.changePassword(_user!.uid, current, next));

  Future<void> signOut() async {
    await _service.signOut();
    _user = null;
    _mode = AuthMode.signIn;
    _errorKey = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _errorKey = null;
    notifyListeners();
    try {
      await action();
      _loading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorKey = e.code;
    } catch (_) {
      _errorKey = 'auth_generic';
    }
    _loading = false;
    notifyListeners();
    return false;
  }
}
