import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

void showSuccessDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: true, // Dışarıya tıklayınca kapanır
    builder: (BuildContext context) {

      // --- OTOMATİK KAPATMA MANTIĞI ---
      Future.delayed(const Duration(seconds: 2), () {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
      // -------------------------------

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yeşil Onay İkonu
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryDarkGreen,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Harika!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  height: 1.4, // Metin okunaklılığı için satır aralığı
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}