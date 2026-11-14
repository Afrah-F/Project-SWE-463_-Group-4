import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations_x.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/app_card.dart';
import '../../widgets/password_field.dart';
import 'auth_header.dart';

/// Sign in. A wrong email or password shows an error under the form; success
/// makes AuthGate (app.dart) show Home.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    auth.clearError();
    if (!_formKey.currentState!.validate()) return;
    await auth.signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  AuthHeader(subtitle: context.t('signin_subtitle')),
                  const SizedBox(height: 24),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.t('log_in'),
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: context.t('email'),
                              hintText: 'example@email.com',
                              prefixIcon: const Icon(Icons.mail_outline),
                            ),
                            validator: (v) {
                              final k = Validators.required(v);
                              return k == null ? null : context.rt(k);
                            },
                          ),
                          const SizedBox(height: 14),
                          PasswordField(
                            controller: _password,
                            label: context.t('password'),
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) {
                              final k = Validators.required(v);
                              return k == null ? null : context.rt(k);
                            },
                          ),
                          if (auth.errorKey != null) ...[
                            const SizedBox(height: 12),
                            Text(context.t(auth.errorKey!),
                                style: const TextStyle(color: AppTheme.danger)),
                          ],
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: auth.loading ? null : _submit,
                            child: auth.loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.4, color: Colors.white),
                                  )
                                : Text(context.t('log_in')),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: auth.loading ? null : auth.showSignUp,
                              child: Text(context.t('no_account')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
