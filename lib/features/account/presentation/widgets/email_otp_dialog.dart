import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/user_notifier.dart';

class EmailOtpSheet extends ConsumerStatefulWidget {
  final String email;
  const EmailOtpSheet({super.key, required this.email});

  @override
  ConsumerState<EmailOtpSheet> createState() => _EmailOtpSheetState();
}

class _EmailOtpSheetState extends ConsumerState<EmailOtpSheet> {
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) t.cancel();
      else setState(() => _seconds--);
    });
  }

  Future<void> _submit() async {
    final otp = _pin.text.trim();
    if (otp.length != 6) return;
    setState(() { _loading = true; _error = false; });

    try {
      final success = await ref.read(userNotifierProvider.notifier).verifyEmailOtp(widget.email, otp);
      if (!mounted) return;
      if (success) Navigator.of(context).pop("OK");
      else _handleError();
    } catch (e) { _handleError(); }
  }

  void _handleError() {
    setState(() { _loading = false; _error = true; });
    _pin.clear();
    _focusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _error = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📐 SMS OTP ÖLÇÜLERİ (baseTheme)
    final baseTheme = PinTheme(
      height: 56,
      width: 50, // 6 hane sığması için 50 idealdir
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white, // Beyaz iç
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _error ? Colors.red : AppColors.primaryDarkGreen,
          width: 2,
        ),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(context).viewInsets.bottom + 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)), // SMS OTP ile aynı
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "E-posta Doğrulama",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "${widget.email} adresine gönderilen 6 haneli kodu giriniz.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
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
              _seconds > 0
                  ? Text(
                "${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')} içinde tekrar gönderebilirsin",
                style: const TextStyle(color: Colors.black54),
              )
                  : TextButton(
                onPressed: () {
                  ref.read(userNotifierProvider.notifier).sendEmailVerification(widget.email);
                  _startTimer();
                },
                child: const Text("Kodu tekrar gönder",
                    style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52, // SMS OTP Ölçüsü
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _error ? Colors.red : AppColors.primaryDarkGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : Text(_error ? "Hatalı Kod" : "Doğrula",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}