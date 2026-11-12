class AppSettings {
  final String languageCode;
  final String currencyCode;
  final bool billRemindersEnabled;
  final bool onboardingDone;

  const AppSettings({
    this.languageCode = 'en',
    this.currencyCode = 'SAR',
    this.billRemindersEnabled = true,
    this.onboardingDone = false,
  });

  AppSettings copyWith({
    String? languageCode,
    String? currencyCode,
    bool? billRemindersEnabled,
    bool? onboardingDone,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      currencyCode: currencyCode ?? this.currencyCode,
      billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }
}
