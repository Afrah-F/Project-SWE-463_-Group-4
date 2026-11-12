import 'package:intl/intl.dart';

/// Currencies offered on "Set up your app" and in Settings.
const Map<String, String> kCurrencies = {
  'SAR': 'Saudi Riyal',
  'USD': 'US Dollar',
  'EUR': 'Euro',
  'GBP': 'British Pound',
  'AED': 'UAE Dirham',
  'KWD': 'Kuwaiti Dinar',
  'QAR': 'Qatari Riyal',
  'EGP': 'Egyptian Pound',
};

final NumberFormat _moneyFormat = NumberFormat('#,##0.00', 'en');

/// "SAR 3,050.00". Western digits are used in both languages so the numbers
/// match the approved Phase 2 screens.
String formatMoney(double amount, String currencyCode) =>
    '$currencyCode ${_moneyFormat.format(amount)}';

String formatNumber(double amount) => _moneyFormat.format(amount);

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

DateTime monthOf(DateTime d) => DateTime(d.year, d.month);

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

String formatMonthYear(DateTime d, String languageCode) =>
    DateFormat.yMMMM(languageCode).format(d);

String formatDayHeader(DateTime d, String languageCode) =>
    DateFormat.yMMMMEEEEd(languageCode).format(d);

String formatShortDate(DateTime d, String languageCode) =>
    DateFormat.yMd(languageCode).format(d);
