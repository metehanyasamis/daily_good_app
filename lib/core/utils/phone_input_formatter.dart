import 'package:flutter/services.dart';

class TurkishPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    final text = newValue.text;

    // 1. Eğer kullanıcı her şeyi silmeye çalışıyorsa veya boşsa +90 bırak
    if (text.length < 4) {
      return const TextEditingValue(
        text: '+90 ',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    // 2. Sadece rakamları ayıkla (ama baştaki 90'ı hariç tut)
    String businessText = text.substring(4);
    final digits = businessText.replaceAll(RegExp(r'[^0-9]'), '');

    // 10 haneden fazlasına izin verme (5xx xxx xx xx)
    final cleanDigits = digits.length > 10 ? digits.substring(0, 10) : digits;

    String formatted = '+90 ';

    // 3. Adım adım formatla
    if (cleanDigits.isNotEmpty) {
      if (cleanDigits.length <= 3) {
        formatted += '(${cleanDigits.substring(0, cleanDigits.length)}';
      } else if (cleanDigits.length <= 6) {
        formatted += '(${cleanDigits.substring(0, 3)}) ${cleanDigits.substring(3)}';
      } else if (cleanDigits.length <= 8) {
        formatted += '(${cleanDigits.substring(0, 3)}) ${cleanDigits.substring(3, 6)}-${cleanDigits.substring(6)}';
      } else {
        formatted += '(${cleanDigits.substring(0, 3)}) ${cleanDigits.substring(3, 6)}-${cleanDigits.substring(6, 8)}-${cleanDigits.substring(8)}';
      }
    }

    // 4. İmleç yönetimi: Eğer kullanıcı siliyorsa imleci koru, ekliyorsa sona at
    int selectionIndex = formatted.length;
    if (newValue.selection.baseOffset < text.length) {
      selectionIndex = newValue.selection.baseOffset;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}