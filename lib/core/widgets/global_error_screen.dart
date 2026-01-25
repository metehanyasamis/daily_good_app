// lib/core/widgets/global_error_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'custom_button.dart';

class GlobalErrorScreen extends StatelessWidget {
  // Mesajı opsiyonel yapalım, varsayılan bir tane kalsın
  final String? message;

  const GlobalErrorScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.wifi_off_rounded, // Daha evrensel bir ikon
                  color: Color(0xFF1B4332),
                  size: 100,
                ),
                const SizedBox(height: 32),
                const Text(
                  "Bağlantı Sorunu",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text(
                  message ?? "Şu anda sunucuyla bağlantı kuramadık.\nLütfen tekrar deneyin.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: "Tekrar Dene",
                    onPressed: () => Phoenix.rebirth(context),
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