/*
import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class EmailVerificationDialog extends StatefulWidget {
  final String email;

  const EmailVerificationDialog({super.key, required this.email});

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 90;
  bool _canResend = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Otomatik onaylama kontrolü
    _otpController.addListener(() {
      final code = _otpController.text.trim();
      if (code.length == 5) {
        FocusScope.of(context).unfocus();
        Future.delayed(const Duration(milliseconds: 300), _confirm);
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 90;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  void _resendCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yeni doğrulama kodu gönderildi')),
    );
    _otpController.clear();
    _errorMessage = null;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _confirm() {
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = "Kod boş olamaz");
      return;
    }
    if (code.length < 5) {
      setState(() => _errorMessage = "Kod 5 haneli olmalıdır");
      return;
    }
    Navigator.of(context).pop(code); // ✅ sadece kodu döndür
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "E-posta Doğrulama",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${widget.email} adresine gönderilen 5 haneli kodu giriniz.",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            /// 🔢 OTP Input
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 5,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Doğrulama Kodu",
                counterText: "",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 16),

            /// 🕒 Sayaç & Yeniden Gönder
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_canResend)
                  Text(
                    "Kalan süre: $minutes:$seconds",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.w600),
                  )
                else
                  GestureDetector(
                    onTap: _resendCode,
                    child: Text(
                      "Yeniden Gönder",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🟢 Doğrulama Butonu
            GestureDetector(
              onTap: _confirm,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryDarkGreen,
                      AppColors.primaryLightGreen
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Text(
                  "Doğrula",
                  style: TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

 */