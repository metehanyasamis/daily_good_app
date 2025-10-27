import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/email_verification_dialog.dart';
import '../../../../core/widgets/info_row_widget.dart';
import '../../../auth/domain/providers/auth_notifier.dart';
import '../../domain/providers/user_notifier.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUser(forceRefresh: false); // ✅
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final userNotifier = ref.read(userNotifierProvider.notifier);
    final user = userState.user;

    Future<void> _logout() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Oturumu Kapat'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Evet, Çıkış Yap'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // 🔐 Tüm verileri temizle
        await PrefsService.clearAll();
        ref.read(authNotifierProvider.notifier).logout();
        ref.read(appStateProvider.notifier).logout();

        // 🔁 Root context'ten login sayfasına yönlendir
        Future.microtask(() {
          GoRouter.of(context).go('/login');
        });
      }
    }


    Future<void> _deleteAccount() async {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Hesabı Sil'),
          content: const Text(
              'Hesabınızı kalıcı olarak silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('İptal')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Evet, Sil'),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await userNotifier.deleteUserAccount();
        context.go('/login');
      }
    }

    // 🧩 E-posta doğrulama akışı
    Future<void> _verifyEmailFlow(String email) async {
      await userNotifier.sendEmailVerification(email);

      final otpCode = await showDialog<String>(
        context: context,
        builder: (_) => EmailVerificationDialog(email: email),
      );

      if (otpCode == null || otpCode.isEmpty) return;

      try {
        await userNotifier.verifyEmailOtp(otpCode);
        final refreshedUser = ref.read(userNotifierProvider).user;
        if (refreshedUser != null && refreshedUser.isEmailVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('E-posta doğrulandı')),
          );
        }
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod geçersiz')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        centerTitle: true,
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async =>
        await ref.read(userNotifierProvider.notifier).loadUser(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 100, // 👈 alt boşluk dinamik
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFFE6F4EA),
                child: Icon(Icons.person,
                    size: 48, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(height: 6),
              Text(
                '${user.name ?? ''} ${user.surname ?? ''}'.trim().isEmpty
                    ? 'Profil Bilgileri Eksik'
                    : '${user.name ?? ''} ${user.surname ?? ''}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 6),

              /// 📍 PROFİL KARTI
              _buildCard(
                title: 'Profil',
                onEdit: () => context.push('/profileDetail'),
                children: [
                  InfoRowWidget(
                    icon: Icons.person_outline,
                    label: 'Ad Soyad',
                    value:
                    '${user.name ?? ''} ${user.surname ?? ''}'.trim().isEmpty
                        ? '-'
                        : '${user.name ?? ''} ${user.surname ?? ''}',
                  ),
                  const SizedBox(height: 6),

                  // 🟢 E-posta
                  InfoRowWidget(
                    icon: Icons.mail_outline,
                    label: 'E-posta',
                    value: user.email?.isNotEmpty == true
                        ? user.email!
                        : '-',
                    isVerified: user.email?.isNotEmpty == true
                        ? user.isEmailVerified
                        : null,
                    onVerify: user.email?.isNotEmpty == true &&
                        user.isEmailVerified == false
                        ? () async =>
                    await _verifyEmailFlow(user.email!)
                        : null,
                  ),
                  const SizedBox(height: 6),

                  InfoRowWidget(
                    icon: Icons.phone_outlined,
                    label: 'Telefon',
                    value: user.phoneNumber,
                    isVerified: user.isPhoneVerified,
                  ),
                  const SizedBox(height: 6),

                  InfoRowWidget(
                    icon: Icons.person_2_outlined,
                    label: 'Cinsiyet',
                    value: user.gender ?? '-',
                  ),
                ],
              ),

              /// 🟢 İSTATİSTİKLER
              const SizedBox(height: 6),
              _buildCard(
                title: 'Kurtardığın Paketler & Kazançların',
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatItem(
                          title: '25 Paket',
                          subtitle: 'Kurtardın',
                          icon: Icons.shopping_bag_outlined),
                      _StatItem(
                          title: '1.465 TL',
                          subtitle: 'Tasarruf Ettin',
                          icon: Icons.savings_outlined),
                      _StatItem(
                          title: '8 kg CO₂',
                          subtitle: 'Önledin',
                          icon: Icons.eco_outlined),
                    ],
                  ),
                  const Divider(height: 18),
                  ListTile(
                    leading: const Icon(Icons.history_outlined,
                        color: Colors.black54),
                    title: const Text('Geçmiş Siparişlerim'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/orders'),
                  ),
                ],
              ),

              /// ⚙️ HESAP AYARLARI
              const SizedBox(height: 6),
              _buildCard(
                title: 'Hesap Ayarları',
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: Colors.black54),
                    title: const Text('Yasal Bilgiler'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined,
                        color: Colors.black54),
                    title: const Text('Bize Ulaşın'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined,
                        color: Colors.black54),
                    title: const Text('Oturumu Kapat'),
                    onTap: _logout,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_off_outlined,
                        color: Colors.red),
                    title: const Text('Hesabımı Kapat',
                        style: TextStyle(color: Colors.red)),
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

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
              const Spacer(),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.primaryDarkGreen),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StatItem(
      {required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryDarkGreen, size: 28),
        const SizedBox(height: 4),
        Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDarkGreen)),
        Text(subtitle, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
