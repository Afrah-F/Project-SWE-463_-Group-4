import 'package:flutter/material.dart';

import '../l10n/app_localizations_x.dart';
import '../theme/app_theme.dart';

/// Centered spinner shown while a provider is loading data.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Shown when loading data failed, with a retry button.
class ErrorView extends StatelessWidget {
  final String messageKey;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.messageKey, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(context.t(messageKey), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: Text(context.t('retry'))),
          ],
        ),
      ),
    );
  }
}
