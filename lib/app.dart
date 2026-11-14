import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/budget_category.dart';
import 'models/expense.dart';
import 'models/savings_goal.dart';
import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/app_shell.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/category_form_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/expense_form_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/savings_goal_form_screen.dart';
import 'services/auth_service.dart';
import 'services/data_repository.dart';
import 'theme/app_theme.dart';

/// Creates every provider and runs the app.
///
/// The two services are passed in so Phase 4 can replace them (Firebase
/// Authentication, sqflite) in main.dart without touching anything else.
class MizaniaApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthService authService;
  final DataRepository repository;

  const MizaniaApp({
    super.key,
    required this.prefs,
    required this.authService,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(prefs),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService)..init(),
        ),
        // The three data providers follow the signed-in user: when the uid
        // changes they load that user's data, when it becomes null they clear.
        ChangeNotifierProxyProvider<AuthProvider, CategoryProvider>(
          create: (_) => CategoryProvider(repository),
          update: (_, auth, previous) =>
              (previous ?? CategoryProvider(repository))..setUser(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(repository),
          update: (_, auth, previous) =>
              (previous ?? ExpenseProvider(repository))..setUser(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthProvider, SavingsProvider>(
          create: (_) => SavingsProvider(repository),
          update: (_, auth, previous) =>
              (previous ?? SavingsProvider(repository))..setUser(auth.user?.uid),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final language =
        context.select<SettingsProvider, String>((s) => s.languageCode);

    return MaterialApp(
      title: 'Mizania',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Arabic switches the whole app to right-to-left automatically.
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

/// Chooses the first screen from the auth state:
/// signed in -> Home shell, first run -> Onboarding, otherwise Sign up / Sign in.
/// Sign up and Sign in are swapped here (not pushed), so there is no stale
/// back stack after signing in or out.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final onboardingDone =
        context.select<SettingsProvider, bool>((s) => s.onboardingDone);

    if (auth.initializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (auth.isSignedIn) return const AppShell();
    if (!onboardingDone) return const OnboardingScreen();
    return auth.mode == AuthMode.signUp ? const SignUpScreen() : const SignInScreen();
  }
}

/// Named routes. Arguments: an [Expense], [BudgetCategory] or [SavingsGoal]
/// to edit it (omit to create), `true` on /onboarding to replay it.
Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final Widget page;
  switch (settings.name) {
    case '/onboarding':
      page = OnboardingScreen(replay: settings.arguments == true);
      break;
    case '/expense-form':
      page = ExpenseFormScreen(expense: settings.arguments as Expense?);
      break;
    case '/category-form':
      page = CategoryFormScreen(category: settings.arguments as BudgetCategory?);
      break;
    case '/savings-goal-form':
      page = SavingsGoalFormScreen(goal: settings.arguments as SavingsGoal?);
      break;
    case '/change-password':
      page = const ChangePasswordScreen();
      break;
    case '/edit-profile':
      page = const EditProfileScreen();
      break;
    default:
      return null;
  }
  return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
}
