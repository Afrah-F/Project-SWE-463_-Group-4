/// Validators return a translation key (or null when valid).
/// The screens translate the key with `context.t(key)`.
class Validators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? required(String? v, {String key = 'err_required'}) =>
      (v == null || v.trim().isEmpty) ? key : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'err_required';
    return _email.hasMatch(v.trim()) ? null : 'err_email';
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'err_required';
    return v.length < 8 ? 'err_password_short' : null;
  }

  static String? confirm(String? v, String original) {
    if (v == null || v.isEmpty) return 'err_required';
    return v == original ? null : 'err_password_match';
  }

  /// Parses a user-typed amount, accepting a comma as decimal separator and
  /// Arabic-Indic digits. Returns null when the text is not a number.
  static double? parseAmount(String? v) {
    if (v == null) return null;
    var s = v.trim();
    if (s.isEmpty) return null;
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    for (var i = 0; i < arabic.length; i++) {
      s = s.replaceAll(arabic[i], '$i');
    }
    s = s.replaceAll('٫', '.').replaceAll(',', '.');
    return double.tryParse(s);
  }

  /// Amount that must be greater than zero.
  static String? positiveAmount(String? v) {
    final n = parseAmount(v);
    if (n == null) return 'err_amount_invalid';
    return n > 0 ? null : 'err_amount_positive';
  }

  /// Amount that may be zero (a category limit of 0 is allowed).
  static String? nonNegativeAmount(String? v) {
    final n = parseAmount(v);
    if (n == null) return 'err_amount_invalid';
    return n >= 0 ? null : 'err_amount_negative';
  }
}
