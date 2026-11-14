import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations_x.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

/// Asks for confirmation, then signs out. AuthGate shows Sign in as soon as the
/// user is cleared. Used by the Home sign-out button and by Settings.
Future<void> confirmAndSignOut(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(ctx.t('sign_out')),
      content: Text(ctx.t('sign_out_confirm')),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(ctx.t('cancel'))),
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(ctx.t('sign_out'),
                style: const TextStyle(color: AppTheme.danger))),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  await context.read<AuthProvider>().signOut();
}
