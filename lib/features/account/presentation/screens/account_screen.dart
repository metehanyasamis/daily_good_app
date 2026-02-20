import 'package:daily_good/features/account/presentation/screens/profile_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/platform/dialogs.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/phone_input_formatter.dart';
import '../../../../core/widgets/info_row_widget.dart';

import '../../../auth/domain/providers/auth_notifier.dart';
import '../../domain/providers/user_notifier.dart';
import '../widgets/email_otp_dialog.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {

  String _formatBirthDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}"
          ".${dt.month.toString().padLeft(2, '0')}"
          ".${dt.year}";
    } catch (_) {
      return "-";
    }
  }

  String _getFormattedPhone(String? phone) {
    if (phone == null || phone.isEmpty) return "-";

    // Sadece rakamları al (Gelen veride +90 veya 0 varsa temizle)
    String cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanDigits.startsWith('90')) cleanDigits = cleanDigits.substring(2);
    if (cleanDigits.startsWith('0')) cleanDigits = cleanDigits.substring(1);

    // Senin meşhur formatter'ını çağırıyoruz
    final formatter = TurkishPhoneFormatter();

    // Formatter'a sanki kullanıcı +90 5xx yazmış gibi boş bir başlangıçtan
    // yeni değere geçiş simülasyonu yaptırıyoruz
    final formattedResult = formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: "+90 $cleanDigits"),
    );

    return formattedResult.text;
  }


// -------------------------------------------------------------
  Future<void> _logout() async {
    // 🎯 Senin PlatformDialogs sınıfını kullandık
    final confirm = await PlatformDialogs.confirm(
      context,
      title: 'Oturumu Kapat',
      message: 'Çıkış yapmak istediğinizden emin misiniz?',
      confirmText: 'Evet, Çıkış Yap',
      cancelText: 'Vazgeç',
      destructive: true, // 🍎 iOS'ta kırmızı font yapar
    );

    if (confirm != true) return;

    await ref.read(authNotifierProvider.notifier).logout();
    await ref.read(appStateProvider.notifier).resetAfterLogout();

    Future.microtask(() {
      if (mounted) {
        context.go('/splash');
      }
    });
  }

  Future<void> _deleteAccountAsync() async {
    final userNotifier = ref.read(userNotifierProvider.notifier);
    await userNotifier.deleteUserAccount();
  }


  Future<void> _deleteAccount() async {
    // 1️⃣ UI'dan SENKRON onay al
    final confirm = await PlatformDialogs.confirm(
      context,
      title: 'Hesabı Sil',
      message: 'Tüm verileriniz silinecek. Emin misiniz?',
      confirmText: 'Evet, Sil',
      cancelText: 'Vazgeç',
      destructive: true,
    );

    if (!mounted || confirm != true) return;

    // 2️⃣ UI referanslarını SABİTLE (artık await yok)
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // 3️⃣ Loader (SYNC)
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => Center(child: PlatformWidgets.loader()),
    );

    try {
      // 4️⃣ ASYNC İŞ (context YOK)
      await _deleteAccountAsync();

      if (!mounted) return;

      // 5️⃣ UI (SYNC)
      navigator.pop();
      router.go('/login');

      Future.microtask(() async {
        await authNotifier.logout();
        await PrefsService.clearAll();
      });
    } catch (_) {
      if (!mounted) return;
      navigator.pop();
    }
  }



  // -------------------------------------------------------------
// AccountScreen içindeki mevcut metodu bununla değiştir:
  Future<void> _verifyEmail(String email) async {
    final notifier = ref.read(userNotifierProvider.notifier);

    // 1. Önce e-posta kodunu gönder
    await notifier.sendEmailVerification(email);

    // 2. Senin yeni BottomSheet'ini aç (EmailVerificationDialog yerine EmailOtpSheet)
    if (mounted) {
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => EmailOtpSheet(email: email), // Senin yeni sheet'in
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref.read(userNotifierProvider.notifier).loadUser(),
    );
  }

  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final user = userState.user;


    // 2) İLK YÜKLEME KONTROLÜ
    // Eğer ne user var ne hata, sistem hala ilk veriyi çekmeye çalışıyordur.
    if (user == null) {
      return Scaffold(
        body: Center(
          child: PlatformWidgets.loader(),
        ),
      );
    }

    // 🔥 TELEFON DOĞRULAMA DURUMU LOGLARI (Mevcut mantığın aynen korundu)
    debugPrint("🚨 [TELEFON_TEYİT] Numara: ${user.phone}");
    debugPrint("🚨 [TELEFON_TEYİT] isPhoneVerified Değeri: ${user.isPhoneVerified}");
    if (!user.isPhoneVerified) {
      debugPrint("⚠️ DİKKAT: OTP ile girildi ama backend 'phone_verified_at' bilgisini boş gönderiyor.");
    }

    // 3) ANA EKRAN (User artık kesinlikle null değil)
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Hesabım",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
      ),

      body: RefreshIndicator(
        onRefresh: () async => ref.read(userNotifierProvider.notifier).loadUser(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              //const SizedBox(height: 5),

              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.textProductCardBrandName,
                    child: Icon(Icons.person, size: 28, color: AppColors.primaryDarkGreen),

                  ),

                  const SizedBox(width: 8),
                  Text(
                    "${user.firstName ?? ''} ${user.lastName ?? ''}".trim().isEmpty
                        ? "Profil Bilgileri Eksik"
                        : "${user.firstName ?? ''} ${user.lastName ?? ''}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),





              const SizedBox(height: 10),

              // -------------------------------------------------- PROFILE CARD
              _buildCard(
                title: "Profil Bilgileri",
                onEdit: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const ProfileDetailsScreen(),
                    ),
                  );
                },
                children: [
                  InfoRowWidget(
                    icon: Icons.mail_outline,
                    label: "E-posta",
                    value: user.email ?? "-",
                    isVerified: user.isEmailVerified,
                    onVerify: (user.email != null && !user.isEmailVerified)
                        ? () {
                      debugPrint("🚨 [UI_TIKLAMA] E-posta doğrulama butonuna basıldı!");
                      _verifyEmail(user.email!);
                    }
                        : null,
                  ),
                  const SizedBox(height: 2),
                  InfoRowWidget(
                    icon: Icons.phone,
                    label: "Telefon",
                    value: _getFormattedPhone(user.phone), // Ortak formatter'dan geçip geldi
                    isVerified: user.isPhoneVerified,
                    onVerify: null,
                  ),
                  const SizedBox(height: 2),
                  InfoRowWidget(
                    icon: Icons.cake,
                    label: "Doğum Tarihi",
                    value: (user.birthDate != null && user.birthDate!.isNotEmpty)
                        ? _formatBirthDate(user.birthDate!)
                        : "-",
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // -------------------------------------------------- SAVING card
              _buildSavingCard(),

              const SizedBox(height: 12),

              // -------------------------------------------------- SETTINGS
              _buildCard(
                title: "Hesap Ayarları",
                children: [
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined),
                    title: const Text("Yasal Bilgiler"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.pushNamed('legal_docs'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text("Bize Ulaşın"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/contact'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Oturumu Kapat"),
                    onTap: _logout,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_forever, color: Colors.red),
                    title: const Text(
                      "Hesabımı Kapat",
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  Widget _buildCard({
    required String title,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.primaryDarkGreen),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  Widget _buildSavingCard() { // Artık parametre almıyor, veriyi ref üzerinden watch ediyoruz
    final userState = ref.watch(userNotifierProvider);
    final stats = userState.user?.statistics;

    return _buildCard(
      title: "Kurtardığın Paketler & Kazançların",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatBox(
              icon: Icons.local_mall_outlined,
              // Backend: total_packages_purchased
              value: "${stats?.totalPackages ?? 0}",
              label: "Paket",
            ),
            _StatBox(
              icon: Icons.savings,
              // Backend: total_savings
              value: "${stats?.totalSavings.toStringAsFixed(0) ?? "0"} TL",
              label: "Tasarruf",
            ),
            _StatBox(
              icon: Icons.eco_outlined,
              // Backend: carbon_footprint_kg
              value: "${stats?.carbonFootprint.toStringAsFixed(1) ?? "0.0"} kg",
              label: "CO₂",
            ),
          ],
        ),
        const SizedBox(height: 10),
        Divider(thickness: 1, color: Colors.grey.shade300),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.history, color: AppColors.primaryDarkGreen),
          title: const Text("Geçmiş Siparişler", style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/order-history'),
        )
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryDarkGreen),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        )
      ],
    );
  }
}
