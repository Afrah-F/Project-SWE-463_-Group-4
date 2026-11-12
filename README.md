# Mizania: Student Budget Tracker

**SWE 463 | Group 04 | Phase 3: Working Flutter Prototype**

Mizania helps students plan a monthly budget, log expenses, track one savings goal and see where their money goes. The app works in English and Arabic (with right-to-left layout) and keeps all budget data on the device.

## How to Run

```bash
flutter pub get
flutter run -d chrome      # or any Android / iOS device or emulator
flutter test               # unit and widget tests
```

There is no test account to prepare. Open the app, finish or skip the welcome screens and create an account on Sign Up (any email, password of at least 8 characters).

## Implemented Phase 3 Features

| # | Feature | Status |
|---|---------|--------|
| 1 | First-run onboarding with language and currency choice | Implemented |
| 2 | Monthly budget with a limit per category (six defaults, total 3,050) | Implemented |
| 3 | Log an expense: amount, category, date, note, monthly repeat | Implemented |
| 4 | Browse, search and filter past expenses (swipe to delete) | Implemented |
| 5 | Add, edit and delete categories with icon and color | Implemented |
| 6 | One savings goal with progress and deposits | Implemented |
| 7 | Monthly spending summary with pie and bar charts | Implemented |
| 8 | Settings: currency, English or Arabic, bill reminders, CSV export, sign out | Implemented |
| 8 | Settings: bill reminders | In progress (switch is saved, notifications are Phase 4) |
| 8 | Settings: CSV export | In progress (CSV is shown and copied, file share is Phase 4) |
| 9 | Account: sign up, sign in, edit profile (name and email), change password, sign out | Implemented (temporary local service) |

## Test the Main Flow

1. Launch the app, tap **Skip Now** (or Next, Next, Get started) and **Create account**.
2. Home shows **SAR 3,050.00** left to spend.
3. Tap **Add expense**, enter `25`, keep the Food chip and tap **Save expense**.
4. Home now shows **SAR 3,025.00**, Food shows 25 of 800 and the expense is under Recent.
5. Open History to search or filter it, tap it to edit, or swipe it to delete.
6. Open Reports to see it in the charts. Open Settings and switch to Arabic to see the whole app flip to right-to-left.

Validation can be seen by saving an expense with an empty amount, creating a category with no name, or entering mismatched passwords.

## Project Structure

```
lib/
  main.dart                  starts the app, creates the two services
  app.dart                   providers, MaterialApp, locale, AuthGate, named routes
  theme/app_theme.dart       Material 3 theme
  models/                    app_user, budget_category, expense, savings_goal, app_settings
  providers/                 auth, category, expense, savings, settings (ChangeNotifier)
  services/                  auth_service, data_repository, recurring_service, csv_export_service
  l10n/                      app_strings (English and Arabic) and the t()/rt() helpers
  utils/                     formatters, validators, icon_registry
  widgets/                   empty_state, category_progress_tile, category_icon_badge,
                             amount_field, section_header, and other shared widgets
  screens/                   onboarding, auth, app_shell and every tab and form screen
test/                        validators, recurring service, auth and data, full app flow
```

## State Management

Provider with `ChangeNotifier`, as approved in Phase 2. `SettingsProvider` and `AuthProvider` are root providers. `CategoryProvider`, `ExpenseProvider` and `SavingsProvider` are `ChangeNotifierProxyProvider`s that follow the signed-in user: when the user changes they load that user's data, and on sign out they clear it. Screen-only state (selected tab, search text, form inputs, selected month) uses `setState`.

## Data Source (Temporary Services)

Two small interfaces separate the app from storage, so Phase 4 can swap the implementation in `main.dart` without touching a screen or provider:

- `AuthService` is implemented by `LocalAuthService` (accounts in `shared_preferences`, salted SHA-256 hash). Phase 4: `FirebaseAuthService`.
- `DataRepository` is implemented by `LocalDataRepository` (JSON in `shared_preferences`, one key per user). Phase 4: an `sqflite` repository.

`LocalAuthService` is for demonstration only and is not production security. No secret, key or token is committed.

## Changes From the Phase 2 Design

| Change | Reason |
|--------|--------|
| Temporary local auth and storage instead of Firebase Authentication and sqflite | Runs from a clean checkout with no Firebase project or `google-services.json`, and works on Chrome where sqflite does not. Both are behind interfaces. |
| Sign up and Sign in are swapped by `AuthGate` instead of named routes | Avoids a stale back stack after signing in or out. Behavior matches the Phase 2 navigation flow. |
| Text lives in `l10n/app_strings.dart` instead of `.arb` files | About 150 short strings and no code generation step to break a fresh checkout. |
| Currency picker is a bottom sheet instead of `DropdownButtonFormField` | Behaves the same on every Flutter version. |
| Change password opens from Edit Profile only, not from a Settings row | Account changes (name, email, password) live in one place and Settings keeps preferences. |
| Home shows "Welcome back" with the user's name and a sign-out button in the top corner | Quick, visible way to sign out from the first screen. |
| CSV export shows and copies the text | `path_provider` and `share_plus` are Phase 4. |
| Added `/edit-profile` route and Edit Profile screen (name and email are editable) | It is in the Phase 2 frames (Settings account card). |

## Packages

| Package | Purpose |
|---------|---------|
| provider | Shared state with ChangeNotifier |
| shared_preferences | Settings, onboarding flag and the temporary account and data storage |
| intl, flutter_localizations | English and Arabic, date formats, right-to-left layout |
| fl_chart | Pie and bar charts on Reports |
| uuid | Unique ids for records |
| crypto | Password hashing in the temporary local auth service |
| cupertino_icons | Default icon font (from the starter) |

## Known Issues

- Bill reminders: the switch is saved but no notification is scheduled yet (Phase 4, `flutter_local_notifications`).
- CSV export is shown in a dialog and copied to the clipboard, not saved as a file.
- Accounts and data exist only on one device and are lost if app data is cleared.
- The "no internet" error state for account screens arrives with Firebase in Phase 4.
- Amounts use Western digits in both languages, matching the Phase 2 screens.

## AI Assistance

ChatGPT was used for design review, documentation refinement, and Flutter debugging. Builder.io was used for AI-assisted UI prototyping. Claude (Anthropic) was used to draft the Phase 3 Flutter implementation (screens, providers, services, tests and this README) from the approved Phase 2 design. Each member must review, run and be able to explain the code they submit.

## Team Members

- Sara Esmaeil
- Shahad Alhassan
- Afrah Alsubhi
- Ghadeer Alsanonah
