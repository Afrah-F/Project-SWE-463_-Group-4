import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';

/// Thrown by an [AuthService]. [code] is a translation key.
class AuthException implements Exception {
  final String code;
  const AuthException(this.code);
  @override
  String toString() => 'AuthException($code)';
}

/// The contract the app depends on. Phase 4 can add a `FirebaseAuthService`
/// that implements this class and swap it in `main.dart`; no screen or
/// provider has to change.
abstract class AuthService {
  /// The user restored from the previous session, or null.
  Future<AppUser?> restoreSession();
  Future<AppUser> signUp(String name, String email, String password);
  Future<AppUser> signIn(String email, String password);
  Future<void> signOut();
  Future<AppUser> updateProfile(String uid, String name, String email);
  Future<void> changePassword(String uid, String currentPassword, String newPassword);
}

/// TEMPORARY on-device implementation used in Phase 3 so the project runs from
/// a clean checkout without a Firebase project or google-services.json.
///
/// Accounts live in SharedPreferences with a salted SHA-256 hash. This is
/// good enough to demonstrate the flow, but it is NOT production security;
/// Firebase Authentication replaces it in Phase 4.
class LocalAuthService implements AuthService {
  static const _usersKey = 'mizania_auth_users';
  static const _sessionKey = 'mizania_auth_session';

  final SharedPreferences _prefs;
  final Duration latency;
  final Uuid _uuid = const Uuid();

  LocalAuthService(this._prefs, {this.latency = const Duration(milliseconds: 500)});

  List<Map<String, dynamic>> _readUsers() {
    final raw = _prefs.getString(_usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> _writeUsers(List<Map<String, dynamic>> users) =>
      _prefs.setString(_usersKey, jsonEncode(users));

  String _salt() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  String _hash(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  AppUser _toUser(Map<String, dynamic> m) => AppUser(
        uid: m['uid'] as String,
        name: m['name'] as String,
        email: m['email'] as String,
      );

  @override
  Future<AppUser?> restoreSession() async {
    final uid = _prefs.getString(_sessionKey);
    if (uid == null) return null;
    for (final u in _readUsers()) {
      if (u['uid'] == uid) return _toUser(u);
    }
    return null;
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    await Future<void>.delayed(latency);
    final users = _readUsers();
    final e = email.trim().toLowerCase();
    if (users.any((u) => u['email'] == e)) {
      throw const AuthException('auth_email_exists');
    }
    final salt = _salt();
    final record = <String, dynamic>{
      'uid': _uuid.v4(),
      'name': name.trim(),
      'email': e,
      'salt': salt,
      'hash': _hash(salt, password),
    };
    users.add(record);
    await _writeUsers(users);
    await _prefs.setString(_sessionKey, record['uid'] as String);
    return _toUser(record);
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    await Future<void>.delayed(latency);
    final e = email.trim().toLowerCase();
    for (final u in _readUsers()) {
      if (u['email'] == e) {
        if (_hash(u['salt'] as String, password) == u['hash']) {
          await _prefs.setString(_sessionKey, u['uid'] as String);
          return _toUser(u);
        }
        break;
      }
    }
    // Same message for unknown email and wrong password.
    throw const AuthException('auth_wrong_credentials');
  }

  @override
  Future<void> signOut() async {
    await _prefs.remove(_sessionKey);
  }

  @override
  Future<AppUser> updateProfile(String uid, String name, String email) async {
    await Future<void>.delayed(latency);
    final users = _readUsers();
    final e = email.trim().toLowerCase();
    // The new email must not belong to a different account.
    if (users.any((u) => u['uid'] != uid && u['email'] == e)) {
      throw const AuthException('auth_email_exists');
    }
    for (final u in users) {
      if (u['uid'] == uid) {
        u['name'] = name.trim();
        u['email'] = e;
        await _writeUsers(users);
        return _toUser(u);
      }
    }
    throw const AuthException('auth_generic');
  }

  @override
  Future<void> changePassword(
      String uid, String currentPassword, String newPassword) async {
    await Future<void>.delayed(latency);
    final users = _readUsers();
    for (final u in users) {
      if (u['uid'] == uid) {
        if (_hash(u['salt'] as String, currentPassword) != u['hash']) {
          throw const AuthException('auth_wrong_current');
        }
        final salt = _salt();
        u['salt'] = salt;
        u['hash'] = _hash(salt, newPassword);
        await _writeUsers(users);
        return;
      }
    }
    throw const AuthException('auth_generic');
  }
}
