import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/user_notifier.dart';

class EmailChangeSheet extends ConsumerStatefulWidget {
  final String currentEmail;
  const EmailChangeSheet({super.key, required this.currentEmail});

  @override
  ConsumerState<EmailChangeSheet> createState() => _EmailChangeSheetState();
}

class _EmailChangeSheetState extends ConsumerState<EmailChangeSheet> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  bool _isOtpSent = false; // Kod gönderildi mi?
  bool _isLoading = false;
  bool _isError = false;

  Timer? _timer;
  int _seconds = 120;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _seconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) t.cancel();
      else if (mounted) setState(() => _seconds--);
    });
  }

  // 1. ADIM: YENİ MAİLE KOD GÖNDER
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || email == widget.currentEmail) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(userNotifierProvider.notifier).sendEmailChangeOtp(email);
      if (mounted) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar(e.toString(), Colors.red);
    }
  }

  // 2. ADIM: KODU DOĞRULA VE GÜNCELLE
  Future<void> _verifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _pinController.text.trim();
    if (otp.length != 6) return;

    setState(() => _isLoading = true);
    try {
      final success = await ref.read(userNotifierProvider.notifier).verifyEmailChangeOtp(email, otp);
      if (mounted) {
        if (success) {
          Navigator.pop(context, "OK"); // Her şey bitti!
        } else {
          _handleOtpError();
        }
      }
    } catch (e) {
      _handleOtpError();
    }
  }

  void _handleOtpError() {
    setState(() {
      _isLoading = false;
      _isError = true;
    });
    _pinController.clear();
    _pinFocusNode.requestFocus();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isError = false);
    });
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📐 PIN TEMASI (SMS ile aynı)
    final baseTheme = PinTheme(
      height: 56, width: 50,
      textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _isError ? Colors.red : AppColors.primaryDarkGreen, width: 2),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(context).viewInsets.bottom + 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SafeArea(
          child: AnimatedSwitcher( // Ekranlar arası yumuşak geçiş
            duration: const Duration(milliseconds: 300),
            child: _isOtpSent ? _buildOtpStep(baseTheme) : _buildEmailStep(),
          ),
        ),
      ),
    );
  }

  // E-POSTA GİRİŞ EKRANI
  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey("email_step"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("E-posta Değiştir", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text("Yeni e-posta adresinizi giriniz. Size bir doğrulama kodu göndereceğiz.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Yeni e-posta adresi",
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryDarkGreen),
            filled: true, fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: AppColors.primaryDarkGreen)),
          ),
        ),
        const SizedBox(height: 24),
        _buildButton(onPressed: _sendOtp, label: "Kod Gönder"),
        const SizedBox(height: 20),
      ],
    );
  }

  // OTP GİRİŞ EKRANI (Pinput)
  Widget _buildOtpStep(PinTheme baseTheme) {
    return Column(
      key: const ValueKey("otp_step"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Kodu Doğrula", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text("${_emailController.text} adresine gönderilen kodu giriniz.",
            textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 24),
        Pinput(
          length: 6,
          controller: _pinController,
          focusNode: _pinFocusNode,
          defaultPinTheme: baseTheme,
          focusedPinTheme: baseTheme.copyWith(
            decoration: baseTheme.decoration!.copyWith(
              border: Border.all(
                color: _isError ? Colors.red : AppColors.primaryDarkGreen,
                width: 3,
              ),
            ),
          ),
          forceErrorState: _isError,
          autofocus: true,
          onCompleted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 24),
        _seconds > 0
            ? Text("${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')} içinde tekrar gönderebilirsin", style: const TextStyle(color: Colors.black54))
            : TextButton(onPressed: _sendOtp, child: const Text("Kodu tekrar gönder", style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold))),
        const SizedBox(height: 24),
        _buildButton(onPressed: _verifyOtp, label: _isError ? "Hatalı Kod" : "Doğrula"),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildButton({required VoidCallback onPressed, required String label}) {
    return SizedBox(
      width: double.infinity, height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isError ? Colors.red : AppColors.primaryDarkGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}