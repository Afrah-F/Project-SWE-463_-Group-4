# Mizania: Student Budget Tracker

**SWE 463 | Group 04 | Phase 3: Working Flutter Prototype**

Mizania is a Flutter budgeting application designed to help students manage monthly expenses, organize category budgets, track savings goals, and analyze spending patterns. It supports English and Arabic, including right-to-left layouts, and stores data locally.

## 1. Getting Started

### Requirements
- Flutter SDK
- Chrome browser or a supported Android/iOS device or emulator

### Run the Application

```bash
flutter pub get
flutter run -d chrome
```

### Run Tests

```bash
flutter analyze
flutter test
```

The application has been integrated and tested successfully by the team. No predefined test account is required. Users can create an account through the Sign Up screen using any valid email and a password of at least eight characters.

## 2. Phase 3 Feature Progress

| # | Feature | Completion |
|---|---|---|
| 1 | Onboarding, language and currency selection | 100% |
| 2 | Monthly budgets and category limits | 100% |
| 3 | Expense logging and monthly recurring expenses | 100% |
| 4 | Expense history, search, filtering and deletion | 100% |
| 5 | Category management with icons and colors | 100% |
| 6 | Savings goals and deposits | 100% |
| 7 | Monthly spending reports and charts | 100% |
| 8 | Settings, language, currency, CSV and reminders | 75% |
| 9 | Account management and profile editing | 100% |

**Estimated implementation completion: 97.2%.**

All Phase 3 core features have been integrated. The remaining Settings functionality—scheduled notifications and file-based CSV sharing—is planned for Phase 4.

## 3. Main Application Flow

1. Launch Mizania and complete or skip onboarding.
2. Create an account and access the Home screen.
3. View the default monthly budget of SAR 3,050.
4. Add a SAR 25 expense under Food.
5. Verify that the remaining budget updates to SAR 3,025.
6. Open History to search, edit or delete the expense.
7. View updated spending charts in Reports.
8. Change the language to Arabic and verify the right-to-left layout.
9. Restart the application and confirm that the account and expenses remain saved.

Forms also validate required fields, email formats, passwords and positive expense amounts.

## 4. Project Structure

```text
lib/
  main.dart
  app.dart
  theme/
  models/
  providers/
  services/
  l10n/
  utils/
  widgets/
  screens/
test/
```

The project separates the user interface, state management, business logic and data services to support maintainability and future development.

## 5. State Management and Data Storage

Mizania uses **Provider with ChangeNotifier** for shared application state.

- `AuthProvider`: Authentication and user sessions.
- `SettingsProvider`: Language, currency and preferences.
- `CategoryProvider`: Categories and budget limits.
- `ExpenseProvider`: Expenses and spending calculations.
- `SavingsProvider`: Savings goals and deposits.

Screen-specific interactions use `setState`.

Temporary Phase 3 services include:

| Component | Phase 3 Implementation | Phase 4 Plan |
|---|---|---|
| Authentication | LocalAuthService | Firebase Authentication |
| Data storage | LocalDataRepository with shared_preferences | SQLite |
| CSV export | Display and clipboard copying | File export and sharing |
| Bill reminders | Saved preference | Scheduled notifications |

Local authentication is intended for prototype demonstration and is not production-grade security.

## 6. Changes From Phase 2

The implementation follows the approved Phase 2 design with selected technical adjustments:

- Replaced Firebase and SQLite with temporary local services to support offline demonstration and Chrome.
- Used `AuthGate` to manage authentication navigation.
- Implemented English and Arabic translations through a Dart localization file.
- Replaced the currency dropdown with a bottom sheet.
- Added the Edit Profile screen for account information.
- Moved Change Password into Edit Profile.
- Used clipboard-based CSV export until file sharing is implemented.

These changes preserve the intended application behavior while simplifying the Phase 3 prototype.

## 7. Dependencies

| Package | Purpose |
|---|---|
| provider | Application state management |
| shared_preferences | Local persistence |
| intl, flutter_localizations | Localization and formatting |
| fl_chart | Spending charts |
| uuid | Unique record identifiers |
| crypto | Temporary password hashing |
| cupertino_icons | UI icons |

## 8. Testing and Verification

The team completed application integration and reported successful automated and manual testing.

Testing covered:

- Account creation, authentication and validation.
- Budget calculations and expense operations.
- Category and savings management.
- Reports and chart updates.
- English and Arabic interfaces.
- Navigation between application screens.
- Local data persistence after restarting.
- Form validation and error handling.

The automated test suite can be rerun using `flutter test`. The application can also be tested manually by following the main application flow above.

## 9. Known Limitations

- Bill reminders do not yet schedule notifications.
- CSV content can be copied but not exported as a file.
- User accounts and budget data are stored locally.
- Firebase-related network error handling is deferred to Phase 4.
- Western numerals are used in both languages.

These limitations are documented for the next development phase.

## 10. AI Assistance

ChatGPT supported design review, documentation refinement and Flutter debugging. Builder.io was used for AI-assisted UI prototyping. Claude (Anthropic) assisted with drafting the Phase 3 Flutter implementation, including screens, providers, services, tests and documentation, based on the approved Phase 2 design.

Team members are responsible for reviewing, testing and understanding their contributions.

## 11. Team Members

- Sara Esmaeil
- Ghadeer Alsanonah
- Afrah Alsubhi

**Repository:** https://github.com/Afrah-F/Project-SWE-463_-Group-4
