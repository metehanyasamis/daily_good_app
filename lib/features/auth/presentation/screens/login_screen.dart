import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/social_button.dart';
import '../../domain/providers/auth_notifier.dart';
import '../../domain/states/auth_state.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();

  bool isLoginTab = true;
  bool isTermsChecked = false;
  bool _isOtpOpen = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isOtpOpen) return;

    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      return _error("Lütfen geçerli bir telefon numarası girin.");
    }

    if (!isTermsChecked) {
      return _error("Lütfen koşulları kabul edin.");
    }

    final auth = ref.read(authNotifierProvider.notifier);

    // 🔍 Telefon kayıtlı mı?
    final exists = await auth.checkPhoneExists(phone);

    if (isLoginTab) {
      if (!exists) return _error("Bu numara kayıtlı değil. Lütfen kayıt olun.");
    } else {
      if (exists) return _error("Bu numara zaten kayıtlı.");
    }

    // 📩 OTP gönder
    await auth.sendOtp(phone);

    setState(() => _isOtpOpen = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpBottomSheet(
        phoneNumber: phone,
        isLogin: isLoginTab,
      ),
    );

    if (mounted) setState(() => _isOtpOpen = false);
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      // OTP doğrulanınca yönlendirme
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      print("⚡ AUTH STATE → ${next.status}");

      if (next.status == AuthStatus.authenticated) {
        final app = ref.read(appStateProvider);

        // Eğer yeni kullanıcıysa → onboarding sürecine gitmeden önce profileDetail'e gitmeli
        if (!app.hasSeenOnboarding) {
          context.go('/profileDetail', extra: {'fromOnboarding': true});
          return;
        }

        // Eski kullanıcı → direkt home
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryLightGreen,
      body: Stack(
        children: [
          // LOGO - üstte sabit
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logos/whiteLogo.png',
                height: 350,
              ),
            ),
          ),

          // ALT BEYAZ PANEL (%40 yukarıdan başlar)
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
                physics: const BouncingScrollPhysics(),
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

                    // Sosyal Girişler
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

                    const SizedBox(height: 12),
                    SocialButton(
                      assetIcon: 'assets/logos/google.png',
                      text: "Google ile devam et",
                      onTap: () {
                        print("Go Home Tıklandı");
                        context.go('/home');
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Tab Bar
  // ----------------------------------------------------
  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          _tabButton("Giriş Yap", true),
          _tabButton("Kayıt Ol", false),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool loginTab) {
    final active = isLoginTab == loginTab;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => isLoginTab = loginTab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryDarkGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------
  // Phone field
  // ----------------------------------------------------
  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixText: "+90 ",
        hintText: "Telefon numarası",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
      ),
    );
  }

  // ----------------------------------------------------
  // Terms
  // ----------------------------------------------------
  Widget _buildTerms() {
    return Row(
      children: [
        Checkbox(
          value: isTermsChecked,
          side: BorderSide.none,
          onChanged: (v) => setState(() => isTermsChecked = v!),
          activeColor: AppColors.primaryDarkGreen,
        ),
        Expanded(
          child: Text(
            "Koşulları kabul ediyorum",
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------
  // Button
  // ----------------------------------------------------
  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _onSubmit,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: AppColors.primaryDarkGreen,
        ),
        child: Text(
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
