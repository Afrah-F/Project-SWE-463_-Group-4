import 'package:flutter_test/flutter_test.dart';
import 'package:mizania/providers/expense_provider.dart';
import 'package:mizania/services/auth_service.dart';
import 'package:mizania/services/data_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('LocalAuthService', () {
    test('sign up, sign out, sign in and wrong password', () async {
      final auth = LocalAuthService(prefs, latency: Duration.zero);
      final user = await auth.signUp('Sara', 'Sara@Example.com', 'password1');
      expect(user.email, 'sara@example.com');

      await auth.signOut();
      expect(await auth.restoreSession(), isNull);

      expect((await auth.signIn('sara@example.com', 'password1')).uid, user.uid);
      expect((await auth.restoreSession())?.uid, user.uid);

      expect(
        () => auth.signIn('sara@example.com', 'wrong-password'),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'auth_wrong_credentials')),
      );
    });

    test('duplicate email is rejected and password can be changed', () async {
      final auth = LocalAuthService(prefs, latency: Duration.zero);
      final user = await auth.signUp('Sara', 'sara@example.com', 'password1');
      expect(
        () => auth.signUp('Other', 'sara@example.com', 'password2'),
        throwsA(isA<AuthException>()),
      );

      await auth.changePassword(user.uid, 'password1', 'newpassword1');
      expect(
        () => auth.changePassword(user.uid, 'password1', 'x'),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'auth_wrong_current')),
      );
      expect((await auth.signIn('sara@example.com', 'newpassword1')).uid, user.uid);
    });

    test('profile name and email can be changed, but not to a taken email', () async {
      final auth = LocalAuthService(prefs, latency: Duration.zero);
      final sara = await auth.signUp('Sara', 'sara@example.com', 'password1');
      await auth.signUp('Other', 'other@example.com', 'password2');

      final updated =
          await auth.updateProfile(sara.uid, 'Sara E.', 'Sara.New@Example.com');
      expect(updated.name, 'Sara E.');
      expect(updated.email, 'sara.new@example.com');
      expect((await auth.signIn('sara.new@example.com', 'password1')).uid, sara.uid);

      // Keeping your own email is fine; another account's email is rejected.
      await auth.updateProfile(sara.uid, 'Sara E.', 'sara.new@example.com');
      expect(
        () => auth.updateProfile(sara.uid, 'Sara E.', 'other@example.com'),
        throwsA(isA<AuthException>()
            .having((e) => e.code, 'code', 'auth_email_exists')),
      );
    });
  });

  group('ExpenseProvider with LocalDataRepository', () {
    test('adding an expense updates state and is saved per user', () async {
      final repo = LocalDataRepository(prefs);
      final provider = ExpenseProvider(repo)..setUser('u1');
      await Future<void>.delayed(Duration.zero); // let the first load finish
      expect(provider.loading, isFalse);
      expect(provider.isEmpty, isTrue);

      await provider.add(
        amount: 12.5,
        categoryId: 'food',
        date: DateTime(2026, 10, 1),
        note: 'Lunch',
      );

      expect(provider.expenses.single.amount, 12.5);
      expect(provider.totalSpent(DateTime(2026, 10, 20)), 12.5);
      expect((await repo.loadExpenses('u1')).single.note, 'Lunch');
      expect(await repo.loadExpenses('someone-else'), isEmpty);
    });
  });
}
