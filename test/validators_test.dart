import 'package:flutter_test/flutter_test.dart';
import 'package:mizania/utils/validators.dart';

void main() {
  test('amount must be a number greater than zero', () {
    expect(Validators.positiveAmount(''), 'err_amount_invalid');
    expect(Validators.positiveAmount('abc'), 'err_amount_invalid');
    expect(Validators.positiveAmount('0'), 'err_amount_positive');
    expect(Validators.positiveAmount('-5'), 'err_amount_positive');
    expect(Validators.positiveAmount('12.50'), isNull);
    expect(Validators.positiveAmount('12,50'), isNull);
    expect(Validators.positiveAmount('١٢٫٥'), isNull); // Arabic digits
  });

  test('category limit may be zero but not negative', () {
    expect(Validators.nonNegativeAmount('0'), isNull);
    expect(Validators.nonNegativeAmount('-1'), 'err_amount_negative');
  });

  test('email and password rules', () {
    expect(Validators.email('nope'), 'err_email');
    expect(Validators.email('a@b.co'), isNull);
    expect(Validators.password('short'), 'err_password_short');
    expect(Validators.password('longenough'), isNull);
    expect(Validators.confirm('x', 'y'), 'err_password_match');
    expect(Validators.confirm('y', 'y'), isNull);
  });
}
