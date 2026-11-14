import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/mizania_logo.dart';

/// Mizania logo + subtitle shared by Sign up and Sign in.
class AuthHeader extends StatelessWidget {
  final String subtitle;
  const AuthHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        const MizaniaLogo(size: 130),
        const SizedBox(height: 4),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.mutedText, fontSize: 13)),
      ],
    );
  }
}
