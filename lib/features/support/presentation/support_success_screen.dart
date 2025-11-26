import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class SupportSuccessScreen extends StatelessWidget {
  const SupportSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Bize Ulaşın"),
        automaticallyImplyLeading: false, // 🔥 GERİ TUŞU KALDIRILDI
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            // 🟢 Başarı İkonu
            Icon(Icons.check_circle_rounded,
                size: 90, color: AppColors.primaryDarkGreen),

            const SizedBox(height: 24),

            // 🟢 Başlık
            const Text(
              "Mesajın Başarıyla Gönderildi!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            // 🟢 Açıklama metni
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "Geri bildirimin bizim için çok değerli.\n"
                    "En kısa sürede seninle iletişime geçeceğiz.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            ),

            const Spacer(),

            // 🟢 Alt buton
            Padding(
              padding: const EdgeInsets.all(20),
              child: CustomButton(
                text: "Ana Sayfaya Dön",
                onPressed: () => context.go('/home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
