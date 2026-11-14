import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';

/// Edit profile (the account card in Settings). Name and email can both be
/// changed, and this is the only place that opens Change password.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    // Drop any error left over from another screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final okMsg = context.rt('profile_saved');

    final ok = await auth.updateProfile(_name.text, _email.text);
    if (!mounted) return;
    if (ok) {
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(okMsg)));
    }
    // On failure the error (for example "email already registered") is shown
    // under the form from AuthProvider.errorKey.
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(context.t('edit_profile'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: context.t('full_name'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        final k = Validators.required(v);
                        return k == null ? null : context.rt(k);
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      decoration: InputDecoration(
                        labelText: context.t('email'),
                        prefixIcon: const Icon(Icons.mail_outline),
                      ),
                      validator: (v) {
                        final k = Validators.email(v);
                        return k == null ? null : context.rt(k);
                      },
                    ),
                    if (auth.errorKey != null) ...[
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
                          : Text(context.t('save_changes')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock_outline, color: AppTheme.primary),
                title: Text(context.t('change_password')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).pushNamed('/change-password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
