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
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF2A8A49), // koyu yeşil
            Color(0xFF4CB96A), // orta ton (parlaklık efekti)
            Color(0xFF6ABF7C), // açık yeşil
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2A8A49).withValues(alpha: 0.2), // %15 shadow
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
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(42),
          ),
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
