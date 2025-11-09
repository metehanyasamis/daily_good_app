import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final double? price;
  final VoidCallback onPressed;
  final bool showPrice; // 🆕 fiyatlı mı sade mi?

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.price,
    this.showPrice = false, // varsayılan: sade buton
  });

  @override
  Widget build(BuildContext context) {
    if (!showPrice) {
      // 🔹 Sade buton (Onboarding / Map)
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF2A8A49),
                Color(0xFF4CB96A),
                Color(0xFF6ABF7C),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    // 🔸 İki bölmeli fiyatlı buton (örneğin sepette)
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          // Sol taraf (yeşil)
          Expanded(
            flex: 6,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(60),
                bottomLeft: Radius.circular(90),
              ),
              onTap: onPressed,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A8A49),
                      Color(0xFF4CB96A),
                      Color(0xFF6ABF7C),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    bottomLeft: Radius.circular(90),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDarkGreen.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Sağ taraf (fiyat alanı)
          Expanded(
            flex: 4,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primaryDarkGreen,
                  width: 1,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(60),
                  bottomRight: Radius.circular(90),
                ),
              ),
              child: Center(
                child: Text(
                  "${price?.toStringAsFixed(2) ?? ''} ₺",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryDarkGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
