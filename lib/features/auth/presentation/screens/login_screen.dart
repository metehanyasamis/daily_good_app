import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/social_button.dart';
import '../../domain/providers/auth_notifier.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool isLoginTab = true;
  bool isTermsChecked = false;
  bool _isOtpOpen = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // PHONE NORMALIZE
  // ---------------------------------------------------------------------------
  String _normalizePhone(String input) {
    // Tüm boşluk ve parantezleri kaldır
    final raw = input.replaceAll(RegExp(r'[^0-9]'), '');

    // 10 hane ise 0 ekle (5xx xxx xx xx -> 05xx xxx xx xx)
    if (raw.length == 10) return "0$raw";
    // 11 hane ve 0 ile başlıyorsa tamamdır
    if (raw.length == 11 && raw.startsWith("0")) return raw;
    // 90 ile başlıyor ve 12 haneyse 90'ı at
    if (raw.startsWith("90") && raw.length == 12) return "0${raw.substring(2)}";

    return raw;
  }

  // ---------------------------------------------------------------------------
  // ERROR SNACKBAR
  // ---------------------------------------------------------------------------
  void _error(String msg) {
    // Eğer widget ağacından ayrılmışsa gösterme
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEND OTP & OPEN BOTTOM SHEET
  // ---------------------------------------------------------------------------
  Future<void> _onSubmit() async {
    // Aynı anda birden fazla OTP isteği göndermeyi engelle
    if (_isOtpOpen) return;

    final input = _phoneController.text.trim();
    final phone = _normalizePhone(input);

    if (phone.length != 11) {
      return _error("Lütfen geçerli bir telefon numarası girin (Örn: 05xx xxx xx xx).");
    }

    if (!isTermsChecked) {
      return _error("Lütfen koşulları kabul edin.");
    }

    final auth = ref.read(authNotifierProvider.notifier);

    // Kayıtlı mı? (API bağlantısı)
    // AuthNotifier'da bu metot senkronize olmalı veya loading state'i gösterilmeli.
    final exists = await auth.isPhoneRegistered(phone);

    if (isLoginTab && !exists) {
      return _error("Bu telefon numarasıyla kayıtlı hesap bulunamadı.");
    }

    if (!isLoginTab && exists) {
      return _error("Bu telefon numarası zaten kayıtlı, giriş yap sekmesine geçiniz.");
    }

    // OTP gönder
    final success = await auth.sendOtp(phone);
    if (!success) {
      return _error("OTP gönderme başarısız oldu. Lütfen tekrar deneyin.");
    }

    setState(() => _isOtpOpen = true);

    // OTP doğrulama ekranını aç
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpBottomSheet(
        phone: phone,
        isLogin: isLoginTab,
      ),
    );

    // Bottom sheet kapandığında state'i resetle
    if (mounted) setState(() => _isOtpOpen = false);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLightGreen,
      body: Stack(
        children: [
          // ---------------------------- LOGO ----------------------------
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logos/whiteLogo.png',
                height: 300,
              ),
            ),
          ),

          // ---------------------------- WHITE PANEL ----------------------------
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTabs(),
                    const SizedBox(height: 28),
                    _buildPhoneField(),
                    const SizedBox(height: 12),
                    _buildTerms(),
                    const SizedBox(height: 16),
                    _buildSubmitButton(),

                    const SizedBox(height: 20),
                    // Sosyal medya butonları
                    SocialButton(
                      assetIcon: 'assets/logos/apple.png',
                      text: "Apple ile devam et",
                      onTap: () {
                        // Implement Apple sign in
                      },
                    ),
                    const SizedBox(height: 12),

                    SocialButton(
                      assetIcon: 'assets/logos/google.png',
                      text: "Google ile devam et",
                      onTap: () {
                        // Implement Google sign in
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABS
  // ---------------------------------------------------------------------------
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          _tab("Giriş Yap", true),
          _tab("Kayıt Ol", false),
        ],
      ),
    );
  }

  Widget _tab(String text, bool value) {
    final active = isLoginTab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLoginTab = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryDarkGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PHONE FIELD
  // ---------------------------------------------------------------------------
  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixText: "+90 ",
        hintText: "Telefon numarası",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        fillColor: AppColors.background,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TERMS CHECKBOX
  // ---------------------------------------------------------------------------
  Widget _buildTerms() {
    return Row(
      children: [
        Checkbox(
          value: isTermsChecked,
          onChanged: (v) => setState(() => isTermsChecked = v!),
          activeColor: AppColors.primaryDarkGreen,
          side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => isTermsChecked = !isTermsChecked),
            child: Text(
              "Koşulları kabul ediyorum",
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SUBMIT BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton() {
    // AuthNotifier'ın loading state'ini dinleyerek butonu disable/enable et
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return GestureDetector(
      onTap: isLoading ? null : _onSubmit,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: isLoading
              ? AppColors.primaryLightGreen.withOpacity(0.7)
              : AppColors.primaryDarkGreen,
        ),
        child: isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          isLoginTab ? "Giriş Yap" : "Kayıt Ol",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}