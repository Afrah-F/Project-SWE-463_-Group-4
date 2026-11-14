import 'package:flutter/material.dart';

/// The Mizania logo (assets/images/logo.png). It already contains the
/// "MIZANIA" wordmark, so it replaces both the icon and the title text.
class MizaniaLogo extends StatelessWidget {
  final double size;
  const MizaniaLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticLabel: 'Mizania',
    );
  }
}
