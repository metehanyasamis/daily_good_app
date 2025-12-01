import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/auth_notifier.dart';

class OtpBottomSheet extends ConsumerStatefulWidget {
  final String phone;
  final bool isLogin;

  const OtpBottomSheet({
    super.key,
    required this.phone,
    required this.isLogin,
  });

  @override
  ConsumerState<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends ConsumerState<OtpBottomSheet> {
  // ---------------------------------------------------
  // STATE
  // ---------------------------------------------------
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _timer;
  int _secondsLeft = 120;

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
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------
  // GET OTP CODE
  // ---------------------------------------------------
  String _getCode() => _pinController.text;

  // ---------------------------------------------------
  // TIMER
  // ---------------------------------------------------
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

// ---------------------------------------------------
// SUBMIT LOGIC (GÜNCEL)
// ---------------------------------------------------
  Future<void> _submit() async {
    final code = _pinController.text.trim();

    if (code.length != 6) return;

    setState(() {
      _loading = true;
      _error = false;
    });

    final auth = ref.read(authNotifierProvider.notifier);

    debugPrint("🔵 [OTP] verifyOtp → phone=${widget.phone} code=$code");

    // ---------------------------------------------------
    // 1) OTP DOĞRULAMA
    // ---------------------------------------------------
    final ok = await auth.verifyOtp(widget.phone, code);

    if (!ok) {
      debugPrint("🔴 [OTP] HATALI KOD → _handleError()");
      _handleError();
      return;
    }

    debugPrint("🟢 [OTP] Kod doğru → login çağrılıyor...");

    // ---------------------------------------------------
    // 2) LOGIN (Yeni mi eski mi belirleniyor)
    // ---------------------------------------------------
    final loginResult = await auth.login(widget.phone, code);

    if (!mounted) return;

    // Bottom sheet kapansın
    Navigator.pop(context);

    debugPrint("✨ [OTP] Login Sonucu → $loginResult");

    // ---------------------------------------------------
    // 3) GO_ROUTER YÖNLENDİRME
    // ---------------------------------------------------

    // Yeni kullanıcı → Profil detay doldurma /profileDetail
    if (loginResult == "NEW") {
      debugPrint("🟡 Yeni kullanıcı → Profil doldurma ekranına yönlendiriliyor");
      context.go('/profileDetail', extra: {'fromOnboarding': true});
      return;
    }

    // Eski kullanıcı → Direkt Home
    if (loginResult == "EXISTING") {
      debugPrint("🟢 Mevcut kullanıcı → Home ekranına yönlendiriliyor");
      context.go('/home');
      return;
    }

    // Hata olduysa
    debugPrint("🔴 Login sırasında hata oluştu");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Giriş yapılamadı, tekrar deneyin"),
        backgroundColor: Colors.redAccent,
      ),
    );
  }



  // ---------------------------------------------------
  // ERROR LOGIC
  // ---------------------------------------------------
  void _handleError() {
    setState(() {
      _loading = false;
      _error = true;
    });

    // 1.2 saniye kırmızı kalsın
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _error = false);
    });

    // kutuları temizle
    _pinController.clear();
    _focusNode.requestFocus();
  }

  // ---------------------------------------------------
  // RESEND OTP
  // ---------------------------------------------------
  Future<void> _resendCode() async {
    if (_secondsLeft != 0) return;

    final auth = ref.read(authNotifierProvider.notifier);
    await auth.sendOtp(widget.phone);

    setState(() {
      _secondsLeft = 120;
      _error = false;
    });

    _pinController.clear();
    _focusNode.requestFocus();
    _startTimer();
  }

  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // PIN temasını oluşturuyoruz
    final defaultPinTheme = PinTheme(
      height: 56,
      width: 56,
      textStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _error ? Colors.red : AppColors.primaryDarkGreen,
          width: 2,
        ),
      ),
    );

    final focusedTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _error ? Colors.red : AppColors.primaryDarkGreen,
          width: 3,
        ),
      ),
    );

    final errorTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red, width: 3),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Doğrulama Kodu",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Telefonunuza gönderilen 6 haneli OTP kodunu giriniz.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // PIN INPUT
              Pinput(
                length: 6,
                controller: _pinController,
                focusNode: _focusNode,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedTheme,
                errorPinTheme: errorTheme,
                forceErrorState: _error,
                autofocus: true,
                onCompleted: (value) => _submit(),
              ),

              const SizedBox(height: 24),

              // TIMER
              if (_secondsLeft > 0)
                Text(
                  "${_secondsLeft ~/ 60}:${(_secondsLeft % 60).toString().padLeft(2, '0')} içinde yeniden gönderebilirsin",
                  style: const TextStyle(color: Colors.black54),
                )
              else
                TextButton(
                  onPressed: _resendCode,
                  child: const Text(
                    "Kodu tekrar gönder",
                    style: TextStyle(
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // SUBMIT BUTTON
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

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
