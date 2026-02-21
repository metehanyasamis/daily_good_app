import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/daily_phone_field.dart';
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
    // Sadece rakamları al
    String raw = input.replaceAll(RegExp(r'[^0-9]'), '');

    // Eğer başında 90 varsa onu at (sunucu 05xx bekliyorsa)
    if (raw.startsWith('90')) {
      raw = raw.substring(2);
    }

    // Başına 0 ekle (05xx formatı için)
    if (raw.length == 10) return "0$raw";
    return raw;
  }

  /*
  String _normalizePhone(String input) {
    final raw = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.length == 10) return "0$raw";
    if (raw.length == 11 && raw.startsWith("0")) return raw;
    if (raw.startsWith("90") && raw.length == 12) return "0${raw.substring(2)}";
    return raw;
  }

   */

/*
  TextInputFormatter _phoneFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      debugPrint('📱 [PHONE_FORMATTER] onTap() - old: ${oldValue.text}, new: ${newValue.text}');
      
      final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length > 10) return oldValue;

      String formatted = '';
      if (digits.isNotEmpty) {
        if (digits.length <= 3) {
          formatted = '($digits';
        } else if (digits.length <= 6) {
          formatted = '(${digits.substring(0, 3)}) ${digits.substring(3)}';
        } else if (digits.length <= 8) {
          formatted = '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
        } else {
          formatted = '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8)}';
        }
      }

      int cursorPosition = formatted.length;
      if (newValue.selection.baseOffset < oldValue.selection.baseOffset && formatted.length < oldValue.text.length) {
        cursorPosition = newValue.selection.baseOffset;
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: cursorPosition.clamp(0, formatted.length)),
      );
    });
  }

   */

  void _error(String msg) {
    if (!mounted) return;

    HapticFeedback.vibrate();

    Toasts.error(context, msg);
  }

  Future<void> _onGoogleLogin() async {
    debugPrint("🖱️ [UI] Google Butonuna tıklandı.");
    final authState = ref.read(authNotifierProvider);
    if (authState.isLoading) return;

    final auth = ref.read(authNotifierProvider.notifier);

    final bool isVerified = await auth.loginWithGoogle();

    if (isVerified) {
      debugPrint("📱 [UI] Google doğrulaması bitti, telefon girişine yönlendiriliyor.");
      if (!mounted) return;

      Toasts.show(context, "Google doğrulandı, lütfen telefonunuzu girin.");

      setState(() {
        isLoginTab = false;
        _phoneController.clear();
      });
    } else {
      final errorMsg = ref.read(authNotifierProvider).errorMessage;
      debugPrint("🛑 [UI] Google login başarısız oldu: $errorMsg");
      if (errorMsg != null) _error(errorMsg);
    }
  }

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

      if (!mounted) return;
      setState(() => _isOtpOpen = true);

      // ❗ await YOK
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => OtpBottomSheet(
          phone: phone,
          isLogin: isLoginTab,
        ),
      ).whenComplete(() {
        // BottomSheet kapandığında çalışır
        if (!mounted) return;
        setState(() => _isOtpOpen = false);
      });
    }
    else if (currentState.status == AuthStatus.error) {
      debugPrint("❌ [UI] Hata Mesajı: ${currentState.errorMessage}");
      _error(currentState.errorMessage ?? "İşlem başarısız");
    }

  }

  // ---------------------------------------------------------------------------
  // UI ANA YAPI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    final bool hasSocial = authState.socialUserData != null;
    final isLoading = authState.isLoading;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryLightGreen,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Arka Plan Logo
            Positioned(
              top: 80, left: 0, right: 0,
              child: Center(
                child: Image.asset('assets/logos/whiteLogo.png', height: 250),
              ),
            ),

            // Beyaz Panel
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              top: MediaQuery.of(context).size.height * 0.40 - (bottomInset > 0 ? 120 : 0),
              left: 0, right: 0, bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  left: 28,
                  right: 28,
                  top: 32,
                  // ✅ içerik klavye altında kalmasın
                  bottom: 32 + bottomInset,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    children: [
                      _buildTabs(hasSocial),
                      const SizedBox(height: 12),

                      if (hasSocial) ...[
                        GestureDetector(
                          onTap: () {
                            ref.read(authNotifierProvider.notifier).clearSocial();
                            setState(() => isLoginTab = true);
                            _phoneController.clear();

                            Toasts.show(context, "Google ile devam etme iptal edildi.");
                          },
                          child: const Text(
                            "Google ile devam etmeyi iptal et",
                            style: TextStyle(
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

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
                        onTap: _onGoogleLogin,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BİLEŞENLERİ (HELPERS)
  // ---------------------------------------------------------------------------

  Widget _buildTabs(bool hasSocial) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          _tab("Giriş Yap", true, hasSocial: hasSocial),
          _tab("Kayıt Ol", false, hasSocial: hasSocial),
        ],
      ),
    );
  }

  Widget _tab(String text, bool value, {required bool hasSocial}) {
    final active = isLoginTab == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (hasSocial && value == true) {
            HapticFeedback.selectionClick();
            Toasts.show(context, "Google doğrulandı. Kayıt akışına devam edin.");
            return;
          }
          setState(() => isLoginTab = value);
        },
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
    debugPrint('📱 [PHONE_FIELD] build()');
    return DailyPhoneField(
      controller: _phoneController,
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
              ? AppColors.primaryLightGreen.withValues(alpha: 0.7)
              : AppColors.primaryDarkGreen,
        ),
        child: isLoading
            ? SizedBox( // 🚀 'const' kaldırıldı
          width: 20,
          height: 20,
          child: PlatformWidgets.loader(
            strokeWidth: 2,
            color: Colors.white,
            radius: 10, // iOS (Cupertino) için ideal boyut
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
                        HapticFeedback.selectionClick();
                        Toasts.show(
                            context,
                            "Sözleşme dökümanı şu an hazırlanıyor, lütfen daha sonra tekrar deneyin.",
                            isError: true // Kırmızı yanması dikkati çeker ve işlemin o an yapılamadığını netleştirir
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