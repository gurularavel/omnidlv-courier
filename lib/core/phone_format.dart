import 'package:flutter/services.dart';

/// Same rules as the web panel's phone fields: digits only, one leading "+", grouped as typed.
/// 050 123 45 67 · +994 50 123 45 67 · 0532 123 45 67 · +90 532 123 45 67 · +7 912 345 67 89
String formatPhone(String value) {
  final plus = value.replaceAll(RegExp(r'[^\d+]'), '').startsWith('+');
  var digits = value.replaceAll(RegExp(r'\D'), '');

  if (plus) {
    if (digits.length > 15) digits = digits.substring(0, 15);
    if (digits.startsWith('994')) return '+${_group(digits, [3, 2, 3, 2, 2])}';
    if (digits.startsWith('90')) return '+${_group(digits, [2, 3, 3, 2, 2])}';
    if (digits.startsWith('1')) return '+${_group(digits, [1, 3, 3, 4])}';
    if (digits.startsWith('7')) return '+${_group(digits, [1, 3, 3, 2, 2])}';
    return '+${_group(digits, [3, 3, 3, 3, 3])}';
  }

  if (digits.startsWith('0')) {
    if (digits.length > 11) digits = digits.substring(0, 11);
    return _group(digits, digits.length == 11 ? [4, 3, 2, 2] : [3, 3, 2, 2]);
  }

  if (digits.length > 9) digits = digits.substring(0, 9);
  return _group(digits, [2, 3, 2, 2]);
}

String _group(String digits, List<int> sizes) {
  final parts = <String>[];
  var i = 0;
  for (final size in sizes) {
    if (i >= digits.length) break;
    final end = (i + size).clamp(0, digits.length);
    parts.add(digits.substring(i, end));
    i = end;
  }
  if (i < digits.length) parts.add(digits.substring(i));
  return parts.join(' ');
}

/// Applies [formatPhone] while typing and keeps the caret after the same digit.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final caret = newValue.selection.baseOffset.clamp(0, text.length);
    final countBefore = text.substring(0, caret).replaceAll(RegExp(r'[^\d+]'), '').length;
    final formatted = formatPhone(text);

    var seen = 0;
    var pos = 0;
    while (pos < formatted.length && seen < countBefore) {
      if (RegExp(r'[\d+]').hasMatch(formatted[pos])) seen++;
      pos++;
    }

    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: pos));
  }
}
