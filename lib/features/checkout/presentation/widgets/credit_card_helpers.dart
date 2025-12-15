import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String formatCardNumberForPreview(String raw) {
  final digits = raw.replaceAll(' ', '');
  if (digits.length <= 4) return digits;
  final last4 = digits.substring(digits.length - 4);
  return '•••• •••• •••• $last4';
}

List<String> groupIntoChunks(String s, int size) {
  final out = <String>[];
  for (var i = 0; i < s.length; i += size) {
    out.add(s.substring(i, i + size > s.length ? s.length : i + size));
  }
  return out;
}

TextInputFormatter cardNumberFormatter(TextEditingController controller) {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) return oldValue;

    final spaced = groupIntoChunks(digits, 4).join(' ');
    return TextEditingValue(
      text: spaced,
      selection: TextSelection.collapsed(offset: spaced.length),
    );
  });
}

TextInputFormatter expiryFormatter(TextEditingController controller) {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    final digits = newValue.text.replaceAll('/', '');
    if (digits.length > 4) return oldValue;

    String formatted = digits;
    if (digits.length > 2) {
      formatted = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });
}
