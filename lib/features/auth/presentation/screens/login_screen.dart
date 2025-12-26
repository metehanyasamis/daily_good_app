import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/social_button.dart';
import '../../../settings/domain/providers/legal_settings_provider.dart';
import '../../domain/providers/auth_notifier.dart';
import '../../domain/states/auth_state.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  // State Değişkenleri
  bool isLoginTab = true;
  bool _isOtpOpen = false;

  // Kayıt Sözleşme Checkboxları
  bool isUyelikAccepted = false;
  bool isKvkkAccepted = false;
  bool isGizlilikAccepted = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // MANTIK FONKSİYONLARI (LOGIC)
  // ---------------------------------------------------------------------------

  String _normalizePhone(String input) {
    final raw = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.length == 10) return "0$raw";
    if (raw.length == 11 && raw.startsWith("0")) return raw;
    if (raw.startsWith("90") && raw.length == 12) return "0${raw.substring(2)}";
    return raw;
  }

  void _error(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  /*
  Future<void> _onSubmit() async {
    if (_isOtpOpen) return;

    final input = _phoneController.text.trim();
    final phone = _normalizePhone(input);

    if (phone.length != 11) {
      return _error("Lütfen geçerli bir telefon numarası girin.");
    }

    // 🔥 KAYIT OL SEKMESİNDE 3 KUTUCUK ZORUNLULUĞU
    if (!isLoginTab) {
      if (!isUyelikAccepted || !isKvkkAccepted || !isGizlilikAccepted) {
        return _error("Lütfen tüm yasal metinleri işaretleyerek onaylayınız.");
      }
    }

    final auth = ref.read(authNotifierProvider.notifier);
    final String currentPurpose = isLoginTab ? "login" : "register";

    final success = await auth.sendOtp(phone, purpose: currentPurpose);

    if (!success) {
      return _error("İşlem başarısız. Lütfen bilgilerinizi kontrol edin.");
    }

    setState(() => _isOtpOpen = true);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpBottomSheet(phone: phone, isLogin: isLoginTab),
    );

    if (mounted) setState(() => _isOtpOpen = false);
  }
*/
  Future<void> _onSubmit() async {
    if (_isOtpOpen) return;

    final input = _phoneController.text.trim();
    final phone = _normalizePhone(input);

    if (phone.length != 11) {
      return _error("Lütfen geçerli bir telefon numarası girin.");
    }

    if (!isLoginTab) {
      if (!isUyelikAccepted || !isKvkkAccepted || !isGizlilikAccepted) {
        return _error("Lütfen tüm yasal metinleri işaretleyerek onaylayınız.");
      }
    }

    final auth = ref.read(authNotifierProvider.notifier);
    final String currentPurpose = isLoginTab ? "login" : "register";

    debugPrint("🚀 [UI] OTP İsteği gönderiliyor: $phone, Purpose: $currentPurpose");

    // 1. İsteği at ve bitmesini bekle
    await auth.sendOtp(phone: phone, purpose: currentPurpose);

    // 2. State'in son halini oku
    final currentState = ref.read(authNotifierProvider);

    debugPrint("🔄 [UI] İstek sonrası durum: ${currentState.status}");

    if (currentState.status == AuthStatus.otpSent) {
      debugPrint("✅ [UI] Başarılı! BottomSheet açılıyor.");
      setState(() => _isOtpOpen = true);

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => OtpBottomSheet(phone: phone, isLogin: isLoginTab),
      );

      if (mounted) setState(() => _isOtpOpen = false);
    }
    else if (currentState.status == AuthStatus.error) {
      // 💡 BACKEND MESAJI BURADA GÖSTERİLİYOR
      debugPrint("❌ [UI] Hata Mesajı: ${currentState.errorMessage}");
      _error(currentState.errorMessage ?? "İşlem başarısız");
    }
  }  // ---------------------------------------------------------------------------
  // UI ANA YAPI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.primaryLightGreen,
      body: Stack(
        children: [
          // Arka Plan Logo
          Positioned(
            top: 80, left: 0, right: 0,
            child: Center(
              child: Image.asset('assets/logos/whiteLogo.png', height: 250),
            ),
          ),

          // Beyaz Panel
          Positioned(
            top: MediaQuery.of(context).size.height * 0.40,
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
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

                    // Sadece Kayıt Ol sekmesinde 3'lü checkbox görünür
                    if (!isLoginTab) ...[
                      const SizedBox(height: 20),
                      LoginLegalCheckbox(
                        uyelikValue: isUyelikAccepted,
                        kvkkValue: isKvkkAccepted,
                        gizlilikValue: isGizlilikAccepted,
                        onUyelikChanged: (v) => setState(() => isUyelikAccepted = v ?? false),
                        onKvkkChanged: (v) => setState(() => isKvkkAccepted = v ?? false),
                        onGizlilikChanged: (v) => setState(() => isGizlilikAccepted = v ?? false),
                      ),
                    ],

                    const SizedBox(height: 24),
                    _buildSubmitButton(isLoading),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "veya",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24), // Çizgi ile Apple butonu arası b
                    SocialButton(
                      assetIcon: 'assets/logos/apple.png',
                      text: "Apple ile devam et",
                      onTap: () {},
                    ),
                    const SizedBox(height: 2),
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
  // UI BİLEŞENLERİ (HELPERS)
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
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
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
          width: 20, height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          isLoginTab ? "Giriş Yap" : "Kayıt Ol",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// YASAL ONAY WIDGETI (3'LÜ CHECKBOX)
// ---------------------------------------------------------------------------

class LoginLegalCheckbox extends ConsumerWidget {
  final bool uyelikValue;
  final bool kvkkValue;
  final bool gizlilikValue;
  final Function(bool?) onUyelikChanged;
  final Function(bool?) onKvkkChanged;
  final Function(bool?) onGizlilikChanged;

  const LoginLegalCheckbox({
    super.key,
    required this.uyelikValue,
    required this.kvkkValue,
    required this.gizlilikValue,
    required this.onUyelikChanged,
    required this.onKvkkChanged,
    required this.onGizlilikChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(legalSettingsProvider);

    // API verisi olsa da olmasa da bu listeyi göstereceğiz
    return Column(
      children: [
        _buildCheckRow(
          context,
          "Üyelik Sözleşmesi",
          settingsAsync.valueOrNull?.contracts['uyelik_sozlesmesi']?.url,
          uyelikValue,
          onUyelikChanged,
        ),
        const SizedBox(height: 12),
        _buildCheckRow(
          context,
          "KVKK Aydınlatma Metni",
          settingsAsync.valueOrNull?.contracts['kvkk_aydinlatma_metni']?.url,
          kvkkValue,
          onKvkkChanged,
        ),
        const SizedBox(height: 12),
        _buildCheckRow(
          context,
          "Gizlilik Sözleşmesi",
          settingsAsync.valueOrNull?.contracts['gizlilik_sozlesmesi']?.url,
          gizlilikValue,
          onGizlilikChanged,
        ),
      ],
    );
  }

  Widget _buildCheckRow(BuildContext context, String text, String? url, bool val, Function(bool?) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24, width: 24,
          child: Checkbox(
            value: val,
            onChanged: onChanged,
            activeColor: AppColors.primaryDarkGreen,
            side: const BorderSide(color: Colors.grey, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
              children: [
                TextSpan(
                  text: text,
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (url != null && url.isNotEmpty && url != "string") {
                        _launchURL(url);
                      } else {
                        // API HATASI DURUMUNDA VERİLECEK UYARI
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sözleşme dökümanı şu an hazırlanıyor, lütfen daha sonra tekrar deneyin.")),
                        );
                      }
                    },
                ),
                const TextSpan(text: " 'ni okudum ve kabul ediyorum."),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String? url) async {
    if (url == null || url.isEmpty || url == "string") return;

    final uri = Uri.parse(url);
    try {
      await launchUrl(
        uri,
        // inAppWebView bazen siyah ekran verebilir, bu mod daha günceldir:
        mode: LaunchMode.inAppBrowserView,
      );
    } catch (e) {
      debugPrint("URL açılırken hata oluştu: $e");
      // Hata olursa tarayıcıda açmayı dene (fallback)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}