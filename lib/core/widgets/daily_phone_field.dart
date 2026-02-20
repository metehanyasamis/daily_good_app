import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // AppColors için
import '../utils/phone_input_formatter.dart';

class DailyPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;

  const DailyPhoneField({
    super.key,
    required this.controller,
    this.enabled = true,
    this.hintText = "Telefon numaranızı girin",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      enabled: enabled,
      inputFormatters: [TurkishPhoneFormatter()],
      decoration: InputDecoration(
        // Artık prefixText: "+90" gerek yok, formatter içine gömdük
        hintText: hintText,
        fillColor: AppColors.background,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: AppColors.primaryDarkGreen, width: 2),
        ),
      ),
    );
  }
}