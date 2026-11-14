import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations_x.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/language_toggle.dart';
import '../../widgets/mizania_logo.dart';
import '../../widgets/option_picker_field.dart';

/// Welcome, How Mizania helps, Set up your app (three pages in one PageView).
///
/// First run: finishing opens Sign up. Replay (from Settings): finishing
/// simply goes back to Settings.
class OnboardingScreen extends StatefulWidget {
  final bool replay;
  const OnboardingScreen({super.key, this.replay = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _pageCount = 3;
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();
    final navigator = Navigator.of(context);
    if (widget.replay) {
      navigator.pop();
      return;
    }
    auth.showSignUp();
    await settings.completeOnboarding(); // AuthGate then shows Sign up
  }

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onDark = _page < 2;
    final fg = onDark ? Colors.white : AppTheme.primary;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: AppTheme.background,
          gradient: onDark
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3F5E4F), Color(0xFF6C7F72), Color(0xFFCFCBC0)],
                )
              : null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [
                    _WelcomePage(),
                    _HelpPage(),
                    _SetupPage(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _finish,
                      style: TextButton.styleFrom(foregroundColor: fg),
                      icon: const Icon(Icons.skip_next, size: 18),
                      label: Text(context.t('skip_now')),
                    ),
                    const Spacer(),
                    for (var i = 0; i < _pageCount; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page ? fg : fg.withAlpha(90),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(120, 46),
                        backgroundColor: onDark ? Colors.white : AppTheme.primary,
                        foregroundColor: onDark ? AppTheme.primary : Colors.white,
                      ),
                      child: Text(_page == _pageCount - 1
                          ? context.t('get_started')
                          : context.t('next')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The logo has dark lettering, so it sits on a white rounded card to
          // stay readable on the green gradient.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            child: const MizaniaLogo(size: 160),
          ),
          const SizedBox(height: 40),
          Text(
            context.t('onb_get_started').toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              context.t('onb_tagline'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String key) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(46),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(context.t(key),
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('onb_help_title'),
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 22),
          row(Icons.receipt_long, 'onb_help_1'),
          row(Icons.account_balance_wallet, 'onb_help_2'),
          row(Icons.pie_chart, 'onb_help_3'),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.lock_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(context.t('onb_privacy'),
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SetupPage extends StatelessWidget {
  const _SetupPage();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currencyOptions = {
      for (final e in kCurrencies.entries) e.key: '${e.key} - ${e.value}',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t('onb_setup_title'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 24),
          Text(context.t('language'),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          LanguageToggle(
            languageCode: settings.languageCode,
            onChanged: settings.setLanguage,
          ),
          const SizedBox(height: 20),
          OptionPickerField(
            label: context.t('currency'),
            valueLabel: currencyOptions[settings.currencyCode] ?? settings.currencyCode,
            sheetTitle: context.t('currency'),
            options: currencyOptions,
            selectedKey: settings.currencyCode,
            onChanged: settings.setCurrency,
          ),
        ],
      ),
    );
  }
}
