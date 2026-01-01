import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'custom_button.dart'; // Dosya yolunu kontrol et

class GlobalErrorScreen extends StatelessWidget {
  const GlobalErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Buradaki MaterialApp, Bootstrap'in barını tamamen kapatır.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          // bottom: true, Android gesture barından kurtarır.
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFF1B4332),
                  size: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  "Bağlantı Sorunu",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Şu anda sunucuyla bağlantı kuramadık.\nLütfen internetini kontrol edip tekrar dene.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                ),
                const Spacer(),

                // Butonun düzgün görünmesi ve tıklanması için:
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Tekrar Dene",
                    onPressed: () {
                      // Tıklama anında uygulamayı tertemiz yeniden başlatır
                      Phoenix.rebirth(context);
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}