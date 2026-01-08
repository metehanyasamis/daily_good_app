// lib/features/contact/presentation/contact_success_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class ContactSuccessScreen extends StatelessWidget {
  const ContactSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 🚀 TÜM STİL PAKETİNİ TEMADAN ÇEK
        backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
        foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
        systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle, // Şebeke simgelerini beyaz yapar
        titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
        centerTitle: AppTheme.greenAppBarTheme.centerTitle,

        title: const Text("Bize Ulaşın"),

        // ⛔ ÖZEL DURUM: Bu ekranda geri butonu istemediğin için bunu ekliyoruz
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            /// ✅ BAŞARI İKONU
            const Icon(
              Icons.check_circle_rounded,
              size: 90,
              color: AppColors.primaryDarkGreen,
            ),

            const SizedBox(height: 24),

            /// ✅ BAŞLIK
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

            /// ✅ AÇIKLAMA
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

            /// ✅ ALT BUTON
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
