import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnidlv_courier/core/phone_format.dart';

void main() {
  test('formats numbers the way the web panel does', () {
    expect(formatPhone('0501234567'), '050 123 45 67');
    expect(formatPhone('050abc1234567'), '050 123 45 67');
    expect(formatPhone('+994501234567'), '+994 50 123 45 67');
    expect(formatPhone('tel: +994 (50) 123-45-67'), '+994 50 123 45 67');
    expect(formatPhone('05321234567'), '0532 123 45 67');
    expect(formatPhone('+905321234567'), '+90 532 123 45 67');
    expect(formatPhone('+79123456789'), '+7 912 345 67 89');
    expect(formatPhone('501234567'), '50 123 45 67');
  });

  test('keeps the caret after the same digit while typing in the middle', () {
    final formatter = PhoneInputFormatter();
    const oldValue = TextEditingValue(text: '050 123 45 67', selection: TextSelection.collapsed(offset: 5));
    // The user typed "9" after "050 1".
    const newValue = TextEditingValue(text: '050 1923 45 67', selection: TextSelection.collapsed(offset: 6));

    final result = formatter.formatEditUpdate(oldValue, newValue);

    expect(result.text, '0501 923 45 67');
    expect(result.selection.baseOffset, 6);
  });
}
