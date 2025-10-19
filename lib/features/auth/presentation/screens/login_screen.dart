import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'otp_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool isTermsChecked = false;
  bool isLoginTab = false;
  bool _isOtpOpen = false;


  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_isOtpOpen) return; // ikinci tıklamayı engelle

    if (_phoneController.text.length == 10 && isTermsChecked) {
      setState(() => _isOtpOpen = true);

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => OtpBottomSheet(
          phoneNumber: _phoneController.text, // 🔸 kullanıcının girdiği numara
        ),
      );

      if (mounted) setState(() => _isOtpOpen = false);
    } else if (!isTermsChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen koşulları kabul edin."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF49A05D),
      body: SafeArea(
        bottom: false, // ⚠️ Alt beyaz panel tam otursun
        child: Column(
          children: [
            // 🔹 Üst Logo Alanı
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  'assets/logos/whiteLogo.png',
                ),
              ),
            ),

            // 🔹 Alt Beyaz Alan (Yuvarlatılmış)
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // 🔸 Sekmeli Kayıt/Giriş Butonları
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F1F1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLoginTab = false),
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 250),
                                    height: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: !isLoginTab
                                          ? Colors.black
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      "Kayıt Ol",
                                      style: TextStyle(
                                        color: !isLoginTab
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLoginTab = true),
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 250),
                                    height: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isLoginTab
                                          ? Colors.black
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      "Giriş Yap",
                                      style: TextStyle(
                                        color: isLoginTab
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // 🔸 Telefon Alanı
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Cep telefonu",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixText: '+90 ',
                            hintText: 'Cep telefonu numaranızı girin',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 1, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xFF6ABF7C), width: 2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔸 Gizlilik kutucuğu
                        Row(
                          children: [
                            Checkbox(
                              value: isTermsChecked,
                              onChanged: (val) => setState(() => isTermsChecked = val!),
                              activeColor: const Color(0xFF6ABF7C),
                              checkColor: Colors.white, // tik rengi
                              side: BorderSide.none, // ✅ kenarlığı kaldırır
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4), // isteğe bağlı yuvarlatma
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Koşulları ve gizlilik politikasını kabul ediyorum.',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

// 🔸 Dinamik Buton
                        GestureDetector(
                          onTap: () {
                            final phone = _phoneController.text.trim();

                            if (phone.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen telefon numaranızı girin.'),
                                ),
                              );
                              return;
                            }

                            if (!isTermsChecked) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lütfen koşulları ve gizlilik politikasını kabul edin.'),
                                ),
                              );
                              return;
                            }

                            // 🔹 OTP BottomSheet aç
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => OtpBottomSheet(
                                phoneNumber: phone, // dinamik telefon numarası
                              ),
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF3E8D4E), Color(0xFF7EDC8A)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isLoginTab ? "Giriş Yap" : "Kayıt Ol",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),


                        // 🔸 “ya da” Çizgisi
                        Row(
                          children: [
                            Expanded(
                                child: Divider(
                                    color: Colors.grey.withOpacity(0.4),
                                    thickness: 1)),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "ya da",
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                            ),
                            Expanded(
                                child: Divider(
                                    color: Colors.grey.withOpacity(0.4),
                                    thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 🔸 Apple Butonu
                        _buildSocialButton(
                          icon: Icons.apple,
                          text: "Apple ile devam et",
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),

                        // 🔸 Google Butonu
                        _buildSocialButton(
                          asset: 'assets/logos/google.png',
                          text: "Google ile devam et",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    IconData? icon,
    String? asset,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.black.withOpacity(0.3)),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 28, color: Colors.black)
            else if (asset != null)
              Image.asset(asset, height: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
