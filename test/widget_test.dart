import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mizania/app.dart';
import 'package:mizania/services/auth_service.dart';
import 'package:mizania/services/data_repository.dart';
import 'package:mizania/widgets/mizania_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  testWidgets('skip welcome, sign up, log an expense, edit account, sign out',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(MizaniaApp(
      prefs: prefs,
      authService: LocalAuthService(prefs, latency: Duration.zero),
      repository: LocalDataRepository(prefs),
    ));
    await tester.pumpAndSettle();

    // First run opens the welcome screens with the logo; Skip Now leads to Sign up.
    expect(find.byType(MizaniaLogo), findsOneWidget);
    await tester.tap(find.text('Skip Now'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
    expect(find.byType(MizaniaLogo), findsOneWidget);

    // Both password fields have their own eye.
    expect(find.byIcon(Icons.visibility), findsNWidgets(2));

    // Validation: empty form shows errors and stays on the screen.
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required.'), findsWidgets);

    // Fill in and create the account.
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Sara');
    await tester.enterText(fields.at(1), 'sara@example.com');
    await tester.enterText(fields.at(2), 'password1');
    await tester.enterText(fields.at(3), 'password1');
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();

    // Home greets the user and shows the seeded budget: 3,050 left to spend.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsOneWidget);
    expect(find.text('Left to spend'), findsOneWidget);
    expect(find.text('SAR 3,050.00'), findsOneWidget);

    // Add a 25 expense.
    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, '25');
    await tester.tap(find.widgetWithText(FilledButton, 'Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('SAR 3,025.00'), findsOneWidget);

    // Settings has no Change Password row; Edit Profile does.
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Change Password'), findsNothing);
    await tester.tap(find.text('sara@example.com'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);

    // The email field is editable and the new email is saved.
    await tester.enterText(find.byType(TextFormField).at(1), 'sara.new@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('Profile saved'), findsOneWidget);
    expect(find.text('sara.new@example.com'), findsOneWidget);

    // Sign out from the Home button, with a confirmation dialog.
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sign out'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilledButton, 'Log In'), findsOneWidget);
  });
}
