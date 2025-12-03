import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/social_button.dart';
import '../../../account/data/models/user_model.dart';
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

  // ---------------------------------------------------------------------------
  // SEND OTP & OPEN SHEET
  // ---------------------------------------------------------------------------
  Future<void> _onSubmit() async {
    if (_isOtpOpen) return;

    final rawPhone = _phoneController.text.trim();
    final phone = _normalizePhone(rawPhone);

    if (rawPhone.length != 10 && phone.length != 11) {
      return _error("Lütfen geçerli bir telefon numarası girin.");
    }

    if (!isTermsChecked) {
      return _error("Lütfen koşulları kabul edin.");
    }

    final auth = ref.read(authNotifierProvider.notifier);
    final isRegistered = await auth.isPhoneRegistered(phone);

    if (isLoginTab) {
      if (!isRegistered) {
        return _error("Bu telefon numarasıyla kayıtlı bir hesap bulunamadı.");
      }
    } else {
      if (isRegistered) {
        return _error("Bu telefon numarası zaten kayıtlı. Giriş yap sekmesine geçiniz.");
      }
    }

    await auth.sendOtp(phone);

    setState(() => _isOtpOpen = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpBottomSheet(
        phone: phone,
        isLogin: isLoginTab,
      ),
    );

    if (mounted) setState(() => _isOtpOpen = false);
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------
  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        final app = ref.read(appStateProvider);

        if (!app.hasSeenOnboarding) {
          context.go('/profileDetail', extra: {'fromOnboarding': true});
        } else {
          context.go('/home');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryLightGreen,
      body: Stack(
        children: [
          // --- LOGO ---
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

          // --- WHITE PANEL ---
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

                    SocialButton(
                      assetIcon: 'assets/logos/apple.png',
                      text: "Apple ile devam et",
                      onTap: _onAppleLogin,
                    ),
                    const SizedBox(height: 12),

                    SocialButton(
                      assetIcon: 'assets/logos/google.png',
                      text: "Google ile devam et",
                      onTap: _onGoogleLogin,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  // ---------------------------------------------------------------------------
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

  String _normalizePhone(String input) {
    if (input.length == 10) return "0$input";
    if (input.startsWith("0") && input.length == 11) return input;
    if (input.startsWith("+90")) return "0${input.substring(3)}";
    return input;
  }

  // ---------------------------------------------------------------------------
  Widget _buildTerms() {
    return Row(
      children: [
        Checkbox(
          value: isTermsChecked,
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

  // ---------------------------------------------------------------------------
  Future<void> _onAppleLogin() async {
    print("🍎 Apple login...");
  }

  // LoginScreen, _LoginScreenState sınıfı içinde

  Future<void> _onGoogleLogin() async {
    print("🔵 Google login atlatılıyor (Gecici Cozum).");

    try {
      // 1. Sahte bir UserModel oluşturun
      final mockUser = UserModel(
        id: "MOCK_SOCIAL_ID",
        firstName: "Test",
        lastName: "Kullanici",
        phone: "99999999999",
        token: "MOCK_SOCIAL_TOKEN_FOR_DIO",
      );

      // 2. Kullanıcı verisini kaydet (Token'ı SharedPrefs'e kaydeder)
      // NOT: Result atamasını kaldırdık. (use_of_void_result çözüldü)
      //await ref.read(userNotifierProvider.notifier).saveUserLocally(mockUser); // Hata veren 275. satır (veya yakını) için düzeltme
      // 3. AuthNotifier'ı 'Authenticated' olarak ayarla
      ref.read(authNotifierProvider.notifier).state = AuthState.authenticated(mockUser);

      // 4. AppState'teki zorunlu bayrakları atlayacak şekilde 'true' yapın
      final appStateNotifier = ref.read(appStateProvider.notifier);

      // NOT: Result atamasını kaldırdık. (use_of_void_result çözüldü)
      await appStateNotifier.setLoggedIn(true);
      //await appStateNotifier.setNewUser(false);

      // HATA VEREN METOTLARIN YERİNE, ÇALIŞTIĞINI GÖRDÜĞÜMÜZ DİĞER METOTLARI KULLANALIM
      // VEYA SADECE setLoggedIn / setNewUser ile yetinelim.
      // Ancak AppState'in zorunlu adımları atlaması için bu iki bayrağı kullanmalıyız.

      // EĞER setHasSeenOnboarding / setHasSelectedLocation yoksa:
      // Lütfen AppStateNotifier sınıfınızdaki bu bayrakları güncelleyen doğru metot isimlerini kullanın.
      // Eğer metotları bulamazsanız, aşağıdaki iki satırı YORUM SATIRINA alın.
      // await appStateNotifier.setHasSeenOnboarding(true); // HATA VEREBİLİR
      // await appStateNotifier.setHasSelectedLocation(true); // HATA VEREBİLİR

      // 5. Yönlendirme komutu: Sadece context.go('/home') ile yönlendirme yapın.
      context.go('/home');

      print("✅ Atlatma Basarili. Uygulama Home akisina yonlendiriliyor.");

    } catch (e) {
      print("❌ Atlatma sirasinda hata olustu: $e");
      _error("Geçici atlatma hatası oluştu.");
    }
  }

  // ---------------------------------------------------------------------------
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
