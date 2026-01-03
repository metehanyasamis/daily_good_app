import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../account/data/models/user_model.dart';
import '../../../account/domain/providers/user_notifier.dart';
import '../../domain/providers/auth_notifier.dart';

class OtpBottomSheet extends ConsumerStatefulWidget {
  final String phone;
  final bool isLogin; // sadece label için

  const OtpBottomSheet({
    super.key,
    required this.phone,
    required this.isLogin,
  });

  @override
  ConsumerState<OtpBottomSheet> createState() => _OtpBottomSheetState();
}

class _OtpBottomSheetState extends ConsumerState<OtpBottomSheet> {
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

    final auth = ref.read(authNotifierProvider.notifier);

    // Notifier'daki sendOtp artık purpose beklediği için bunu ekliyoruz
    await ref.read(authNotifierProvider.notifier).sendOtp(
      phone: widget.phone,
      purpose: widget.isLogin ? 'login' : 'register',
    );

    setState(() {
      _seconds = 120;
      _error = false;
    });

    _pin.clear();
    _focusNode.requestFocus();
    _startTimer();
  }

  // ---------------------------------------------------------------------------
  // SUBMIT
  // ---------------------------------------------------------------------------
  Future<void> _submit() async {
    debugPrint("🔘 [UI-OTP] Doğrula butonuna basıldı. Amaç: ${widget.isLogin ? 'Giriş' : 'Kayıt'}");
    final code = _pin.text.trim();
    if (code.length != 6) return;

    setState(() { _loading = true; _error = false; });

    try {
      final auth = ref.read(authNotifierProvider.notifier);
      final userNotif = ref.read(userNotifierProvider.notifier);

      final userModel = await auth.verifyOtpModel(
        widget.phone,
        code,
        isLogin: widget.isLogin,
      );

      if (userModel != null) {
        debugPrint("💾 [UI-OTP] UserNotifier.saveUser çağrılıyor...");
        await userNotif.saveUser(userModel);

        if (!mounted) return;

        if (widget.isLogin) {
          debugPrint("🚢 [UI-OTP] Giriş başarılı, ana sayfaya...");
          context.go("/home");
        } else {
          debugPrint("🚢 [UI-OTP] Kayıt başarılı, profil detayına (isFromRegister: true) ile gidiliyor...");

          // 🔥 TEK DEĞİŞİKLİK BURASI: extra ekledik
          context.go("/profileDetail", extra: true);
        }
      } else {
        debugPrint("🚨 [UI-OTP] İşlem başarısız (User null), hata gösteriliyor.");
        _handleError();
      }
    } catch (e) {
      debugPrint("💥 [UI-OTP] CRASH: $e");
      _handleError();
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------
  void _handleError() {
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

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final baseTheme = PinTheme(
      height: 56,
      width: 56,
      textStyle: const TextStyle(
        fontSize: 24,
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Doğrulama Kodu",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                "Telefonunuza gönderilen 6 haneli kodu giriniz.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
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