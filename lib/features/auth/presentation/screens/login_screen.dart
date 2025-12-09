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
    final raw = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (raw.length == 10) return "0$raw";
    if (raw.length == 11 && raw.startsWith("0")) return raw;
    if (raw.startsWith("90") && raw.length == 12) return "0${raw.substring(2)}";

    return raw;
  }

  // ---------------------------------------------------------------------------
  // ERROR SNACKBAR
  // ---------------------------------------------------------------------------
  void _error(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SEND OTP
  // ---------------------------------------------------------------------------

  Future<void> _onSubmit() async {
    if (_isOtpOpen) return;

    final input = _phoneController.text.trim();
    final phone = _normalizePhone(input);

    if (phone.length != 11) {
      return _error("Lütfen geçerli bir telefon numarası girin.");
    }

    if (!isTermsChecked) {
      return _error("Lütfen koşulları kabul edin.");
    }

    // ❌ ARTIK isPhoneRegistered KULLANMIYORUZ
    // Backend kimin mevcut / yeni olduğunu kendisi bilecek
    final auth = ref.read(authNotifierProvider.notifier);
    final success = await auth.sendOtp(phone);

    if (!success) {
      return _error("OTP gönderilemedi. Lütfen tekrar deneyin.");
    }

    setState(() => _isOtpOpen = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpBottomSheet(
        phone: phone,
        isLogin: isLoginTab, // 👉 Login mi, Kayıt mı bilgisi buradan
      ),
    );

    if (mounted) {
      setState(() => _isOtpOpen = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.primaryLightGreen,
      body: Stack(
        children: [
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
                    _buildSubmitButton(isLoading),

                    const SizedBox(height: 20),
                    SocialButton(
                      assetIcon: 'assets/logos/apple.png',
                      text: "Apple ile devam et",
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),

                    SocialButton(
                      assetIcon: 'assets/logos/google.png',
                      text: "Google ile devam et",
                      onTap: () {},
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
  // UI Helpers
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

  Widget _buildSubmitButton(bool isLoading) {
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
