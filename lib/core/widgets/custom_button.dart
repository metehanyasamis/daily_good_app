import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFilled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isFilled
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A8A49), // koyu yeşil
            Color(0xFF6ABF7C), // açık yeşil
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      )
          : BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: AppColors.primaryDarkGreen),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0, // gölgeyi dış container veriyor
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isFilled ? Colors.white : AppColors.primaryDarkGreen,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
