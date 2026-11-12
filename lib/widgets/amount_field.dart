import 'package:flutter/material.dart';

import '../l10n/app_localizations_x.dart';
import '../utils/validators.dart';

/// Large amount input with the currency label above it.
/// Used by Add expense and the Savings goal deposit field.
class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencyCode;
  final String? labelKey;
  final String? Function(String?)? validator;
  final bool autofocus;

  const AmountField({
    super.key,
    required this.controller,
    required this.currencyCode,
    this.labelKey,
    this.validator,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: '${context.t(labelKey ?? 'amount')} ($currencyCode)',
        hintText: '0.00',
      ),
      validator: (v) {
        final key = (validator ?? Validators.positiveAmount)(v);
        // Validators run outside build, so they must use rt (read), not t.
        return key == null ? null : context.rt(key);
      },
    );
  }
}
