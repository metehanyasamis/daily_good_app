import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomConfirmBar extends StatelessWidget {
  final String label;
  final String amount;
  final VoidCallback onPressed;

  const CustomConfirmBar({
    super.key,
    required this.label,
    required this.amount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPadding + 8,
          left: 16,
          right: 16,
        ),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(60),
              topRight: Radius.circular(60),
              bottomLeft: Radius.circular(90),
              bottomRight: Radius.circular(90),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 🟢 Sol taraf (Sepeti Onayla)
              Expanded(
                child: InkWell(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    bottomLeft: Radius.circular(90),
                  ),
                  onTap: onPressed,
                  splashColor: Colors.white.withOpacity(0.1),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF6ABF7C),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(60),
                        bottomLeft: Radius.circular(90),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // 💰 Sağ taraf (Tutar)
              Container(
                width: 120,
                alignment: Alignment.centerRight, // 🔹 Sağ hizaya sabitle
                padding: const EdgeInsets.only(right: 20), // 🔹 İçerik sağdan biraz boşluk alsın
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(60),
                    bottomRight: Radius.circular(90),
                  ),
                ),
                child: Text(
                  amount,
                  textAlign: TextAlign.right, // 🔹 Text sağa hizalı kalsın
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
