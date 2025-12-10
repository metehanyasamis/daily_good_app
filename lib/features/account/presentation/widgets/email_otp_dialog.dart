import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/user_notifier.dart';

class EmailOtpDialog extends ConsumerStatefulWidget {
  final String email;

  const EmailOtpDialog({super.key, required this.email});

  @override
  ConsumerState<EmailOtpDialog> createState() => _EmailOtpDialogState();
}

class _EmailOtpDialogState extends ConsumerState<EmailOtpDialog> {
  final TextEditingController _pin = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _seconds = 120;
  bool _loading = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    print("📧 [EMAIL OTP] Dialog açıldı → ${widget.email}");
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // TIMER
  // ---------------------------------------------------------------------------
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // RESEND OTP
  // ---------------------------------------------------------------------------
  Future<void> _resend() async {
    if (_seconds != 0) return;

    print("📧 [EMAIL OTP] Tekrar gönderiliyor → ${widget.email}");

    final user = ref.read(userNotifierProvider.notifier);
    await user.sendEmailVerification(widget.email);

    setState(() {
      _seconds = 120;
      _error = false;
    });

    _pin.clear();
    _focusNode.requestFocus();
    _startTimer();
  }

  // ---------------------------------------------------------------------------
  // OTP SUBMIT
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    final otp = _pin.text.trim();

    if (otp.length != 6) {
      print("❌ [EMAIL OTP] Kod eksik → $otp");
      return;
    }

    setState(() {
      _loading = true;
      _error = false;
    });

    print("📧 [EMAIL OTP] Doğrulama istek atılıyor → $otp");

    final notifier = ref.read(userNotifierProvider.notifier);

    try {
      await notifier.verifyEmailOtp(widget.email, otp);

      if (!mounted) return;

      print("✅ [EMAIL OTP] Başarılı!");
      Navigator.of(context).pop("OK");

    } catch (e) {
      print("❌ [EMAIL OTP] Hatalı kod → $otp | HATA = $e");

      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = true;
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() => _error = false);
      });

      _pin.clear();
      _focusNode.requestFocus();
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final baseTheme = PinTheme(
      height: 56,
      width: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _error ? Colors.red : AppColors.primaryDarkGreen,
          width: 2,
        ),
      ),
    );

    return WillPopScope(
      onWillPop: () async => false, // ❌ Geri tuşunu devre dışı bırak
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "E-posta Doğrulama",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Text(
                "${widget.email} adresine gönderilen 6 haneli kodu giriniz.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // -------------------- PIN INPUT --------------------
              Pinput(
                length: 6,
                controller: _pin,
                focusNode: _focusNode,
                defaultPinTheme: baseTheme,
                focusedPinTheme: baseTheme.copyWith(
                  decoration: baseTheme.decoration!.copyWith(
                    border: Border.all(
                      color: _error ? Colors.red : AppColors.primaryDarkGreen,
                      width: 3,
                    ),
                  ),
                ),
                errorPinTheme: baseTheme.copyWith(
                  decoration: baseTheme.decoration!.copyWith(
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                ),
                forceErrorState: _error,
                autofocus: true,
                onCompleted: (_) => _submit(),
              ),

              const SizedBox(height: 24),

              // -------------------- TIMER --------------------
              _seconds > 0
                  ? Text(
                "${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')} içinde tekrar gönderebilirsin",
                style: const TextStyle(color: Colors.black54),
              )
                  : TextButton(
                onPressed: _resend,
                child: const Text(
                  "Kodu tekrar gönder",
                  style: TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // -------------------- BUTTON --------------------
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _error ? Colors.red : AppColors.primaryDarkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    _error ? "Hatalı Kod" : "Doğrula",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
