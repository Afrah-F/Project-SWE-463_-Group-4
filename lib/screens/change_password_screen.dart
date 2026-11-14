import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/password_field.dart';

/// Change password. Opened from Edit Profile only. Each of the three fields has
/// its own eye. A wrong current password is shown under that field; success
/// shows "Password changed" and returns to Edit Profile.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _wrongCurrent = false;

  @override
  void initState() {
    super.initState();
    // Drop any error left over from another screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    _wrongCurrent = false;
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final okMsg = context.rt('password_changed');

    final ok = await auth.changePassword(_current.text, _new.text);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(okMsg)));
    } else if (auth.errorKey == 'auth_wrong_current') {
      _wrongCurrent = true;
      _formKey.currentState!.validate(); // re-run so the field shows the error
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('change_password'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(context.t('change_password_hint'),
                style: const TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    PasswordField(
                      controller: _current,
                      label: context.t('current_password'),
                      textInputAction: TextInputAction.next,
                      onChanged: (_) => _wrongCurrent = false,
                      validator: (v) {
                        final k = Validators.required(v);
                        if (k != null) return context.rt(k);
                        return _wrongCurrent ? context.rt('auth_wrong_current') : null;
                      },
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _new,
                      label: context.t('new_password'),
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final k = Validators.password(v);
                        return k == null ? null : context.rt(k);
                      },
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: _confirm,
                      label: context.t('confirm_new_password'),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      validator: (v) {
                        final k = Validators.confirm(v, _new.text);
                        return k == null ? null : context.rt(k);
                      },
                    ),
                    if (auth.errorKey != null && auth.errorKey != 'auth_wrong_current') ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(context.t(auth.errorKey!),
                            style: const TextStyle(color: AppTheme.danger)),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: auth.loading ? null : _save,
                      child: auth.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text(context.t('save_new_password')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
