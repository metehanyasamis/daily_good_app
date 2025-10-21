import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
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
    if (_isOtpOpen) return;

    if (_phoneController.text.length == 10 && isTermsChecked) {
      setState(() => _isOtpOpen = true);
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => OtpBottomSheet(
          phoneNumber: _phoneController.text.trim(),
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
      backgroundColor: AppColors.primaryLightGreen, // üst logo alanı için açık arka plan
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Üst Logo Alanı
            Expanded(
              flex: 4,
              child: Center(
                child: Image.asset(
                  'assets/logos/whiteLogo.png',
                ),
              ),
            ),

            // Alt Beyaz Alan
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Sekmeli Kayıt / Giriş Butonları
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLoginTab = false),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    height: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: !isLoginTab
                                          ? AppColors.primaryDarkGreen
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      "Kayıt Ol",
                                      style: !isLoginTab
                                          ? Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.surface)
                                          : Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => isLoginTab = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    height: 52,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isLoginTab
                                          ? AppColors.primaryDarkGreen
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Text(
                                      "Giriş Yap",
                                      style: isLoginTab
                                          ? Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.surface)
                                          : Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.textPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Telefon Alanı
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Cep telefonu",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
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
                            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.textPrimary.withValues(alpha: 51)),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primaryDarkGreen, width: 2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Gizlilik kutucuğu
                        Row(
                          children: [
                            Checkbox(
                              value: isTermsChecked,
                              onChanged: (val) => setState(() => isTermsChecked = val!),
                              activeColor: AppColors.primaryDarkGreen,
                              checkColor: AppColors.surface,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            Expanded(
                              child: Text(
                                'Koşulları ve gizlilik politikasını kabul ediyorum.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Dinamik Buton (CustomButton kullanılıyor)
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: isLoginTab ? "Giriş Yap" : "Kayıt Ol",
                            onPressed: _onSubmit,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // “ya da” Çizgisi
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppColors.gray.withValues(alpha: 102), thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                "ya da",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                            Expanded(child: Divider(color: AppColors.gray.withValues(alpha: 102), thickness: 1)),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Apple Butonu
                        _buildSocialButton(
                          icon: Icons.apple,
                          text: "Apple ile devam et",
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),

                        // Google Butonu
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

  Widget _buildSocialButton({IconData? icon, String? asset, required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.textPrimary.withValues(alpha: 77)), // %30
          color: AppColors.surface,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, size: 28, color: AppColors.textPrimary)
            else if (asset != null)
              Image.asset(asset, height: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
