import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/info_row_widget.dart';

import '../../../auth/domain/providers/auth_notifier.dart';
import '../../../saving/providers/saving_provider.dart';
import '../../domain/providers/user_notifier.dart';
import '../../domain/states/user_state.dart';
import '../widgets/email_otp_dialog.dart';
import 'legal_documents_screen.dart';

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


// -------------------------------------------------------------
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('Oturumu Kapat'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text('Evet, Çıkış Yap'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 1) Tüm state'leri temizle
    await ref.read(authNotifierProvider.notifier).logout();
    await ref.read(appStateProvider.notifier).resetAfterLogout();

    // 2) 🔥 Yönlendirmeyi microtask ile yap → dialog tamamen kapansın
    Future.microtask(() {
      if (mounted) {
        context.go('/splash');
      }
    });
  }


  Future<void> _deleteAccount() async {
    // 1. Önce gerekli araçları context ölmeden kopyala
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // 🎯 KRİTİK: GoRouter'ı direkt değişkene al
    final router = GoRouter.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Tüm verileriniz silinecek. Emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Loading göster
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      debugPrint("🕹️ [UI] Backend silme başlıyor...");
      await userNotifier.deleteUserAccount();

      // 🎯 BURASI EN ÖNEMLİ KISIM:
      // Önce yönlendiriyoruz. Ekranda AccountScreen kalmadığı için çökme riski bitiyor.
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Loading'i kapat
        router.go('/login'); // Login'e kaç!

        // 3. Login ekranına geçiş başladıktan hemen sonra yereli süpür
        // Future.microtask veya kısa bir delay ile yaparsak AccountScreen dispose olur.
        Future.delayed(const Duration(milliseconds: 100), () async {
          await authNotifier.logout();
          await PrefsService.clearAll();
          debugPrint("🏁 [UI] Tertemiz oldu.");
        });
      }
    } catch (e) {
      debugPrint("💥 [UI-HATA] $e");
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
    final saving = ref.watch(savingProvider);
    final user = userState.user;

    // 🔥 TELEFON DOĞRULAMA DURUMUNU BURADA RÖNTGENLİYORUZ
    if (user != null) {
      debugPrint("🚨 [TELEFON_TEYİT] Numara: ${user.phone}");
      debugPrint("🚨 [TELEFON_TEYİT] isPhoneVerified Değeri: ${user.isPhoneVerified}");

      // Eğer false geliyorsa, Ali'ye atmak için ekran görüntüsü alacağın yer burası:
      if (!user.isPhoneVerified) {
        debugPrint("⚠️ DİKKAT: OTP ile girildi ama backend 'phone_verified_at' bilgisini boş gönderiyor.");
      }
    }

    // 1) İLK YÜKLEME KONTROLÜ
    // Eğer elimizde hiç user yoksa ve hala yükleniyorsa o zaman tam ekran loading göster.
    if (user == null && userState.status == UserStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2) HATA KONTROLÜ
    // Eğer user hala null ise ve hata varsa hata ekranı göster.
    if (user == null && userState.status == UserStatus.error) {
      return Scaffold(
        body: Center(
          child: Text(
            "Hata oluştu:\n${userState.errorMessage ?? 'Bilinmeyen hata'}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    // 3) GÜVENLİK KONTROLÜ
    // Eğer ne hata var ne user, yine loading.
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // BURADAN SONRASI: user artık kesinlikle null değil.
    // Profil güncellense bile (loading olsa bile) eski veri ekranda kalmaya devam eder,
    // böylece 'puf' diye uçma veya geri gelince patlama olmaz.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        centerTitle: true,
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
        // Güncelleme sırasında minik bir gösterge istersen buraya ekleyebilirsin
        bottom: userState.status == UserStatus.loading
            ? const PreferredSize(
            preferredSize: Size.fromHeight(2),
            child: LinearProgressIndicator(minHeight: 2))
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(userNotifierProvider.notifier).loadUser(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const CircleAvatar(
                radius: 34,
                backgroundColor: Color(0xFFE6F4EA),
                child: Icon(Icons.person, size: 40, color: AppColors.primaryDarkGreen),
              ),

              const SizedBox(height: 12),
              Text(
                "${user.firstName ?? ''} ${user.lastName ?? ''}".trim().isEmpty
                    ? "Profil Bilgileri Eksik"
                    : "${user.firstName ?? ''} ${user.lastName ?? ''}",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------- PROFILE CARD
              _buildCard(
                title: "Profil",
                onEdit: () => context.push('/profileDetail'),
                children: [
                  InfoRowWidget(
                    icon: Icons.person,
                    label: "Ad Soyad",
                    value:
                    "${user.firstName ?? ''} ${user.lastName ?? ''}".trim().isEmpty
                        ? "-"
                        : "${user.firstName ?? ''} ${user.lastName ?? ''}",
                  ),
                  const SizedBox(height: 8),
                  InfoRowWidget(
                    icon: Icons.mail_outline,
                    label: "E-posta",
                    value: user.email ?? "-",
                    isVerified: user.isEmailVerified,
                    onVerify: (user.email != null && !user.isEmailVerified)
                        ? () {
                      print("🚨 [UI_TIKLAMA] E-posta doğrulama butonuna basıldı!"); // <--- BU LOGU EKLE
                      _verifyEmail(user.email!);
                    }
                        : null,
                  ),
                  const SizedBox(height: 8),
                  InfoRowWidget(
                    icon: Icons.phone,
                    label: "Telefon",
                    value: user.phone,
                    // 🎯 KRİTİK MANTIK: Eğer phone_verified_at doluysa (true ise) DOĞRULANMIŞTIR.
                    // Modelimizde bunu zaten check ettik.
                    isVerified: user.isPhoneVerified,

                    // Madem zaten doğrulanmadan içeri giremez,
                    // onVerify'ı null yaparsak o "Şimdi Doğrula" butonu ASLA çıkmaz.
                    onVerify: null,
                  ),
                  const SizedBox(height: 8),
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
                    onTap: () {
                      debugPrint("🔍 [AccountScreen] Yasal Bilgiler'e tıklandı.");
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LegalDocumentsScreen()),
                      );
                    },
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
                    leading:
                    const Icon(Icons.delete_forever, color: Colors.red),
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
            color: Colors.black.withOpacity(0.05),
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
              value: "${stats?.totalSavings?.toStringAsFixed(0) ?? "0"} TL",
              label: "Tasarruf",
            ),
            _StatBox(
              icon: Icons.eco_outlined,
              // Backend: carbon_footprint_kg
              value: "${stats?.carbonFootprint?.toStringAsFixed(1) ?? "0.0"} kg",
              label: "CO₂",
            ),
          ],
        ),
        const Divider(height: 24),
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
            color: AppColors.primaryDarkGreen.withOpacity(0.1),
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
