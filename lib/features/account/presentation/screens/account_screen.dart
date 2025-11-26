import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/email_verification_dialog.dart';
import '../../../../core/widgets/info_row_widget.dart';
import '../../../auth/domain/providers/auth_notifier.dart';
import '../../../saving/model/saving_model.dart';
import '../../../saving/providers/saving_provider.dart';
import '../../domain/providers/user_notifier.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {

  // ----------------------------------------------------------
  // LOGOUT — CLASS LEVEL → CRASH YOK
  // ----------------------------------------------------------
  Future<void> _logout() async {
    debugPrint("🚪 Logout dialog opened");

    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Oturumu Kapat'),
          content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Evet, Çıkış Yap'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await ref.read(authNotifierProvider.notifier).logout();
    await PrefsService.clearAll();

    if (!mounted) return;

    // 🔥 ShellRoute içinde olduğun için router'ı resetlemek zorundasın!
    Future.microtask(() {
      GoRouter.of(context).go('/login');
    });
  }



  // ----------------------------------------------------------
  // DELETE ACCOUNT — CLASS LEVEL
  // ----------------------------------------------------------
  Future<void> _deleteAccount() async {
    final userNotifier = ref.read(userNotifierProvider.notifier);

    final confirm = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Hesabınızı kalıcı olarak silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await userNotifier.deleteUserAccount();

    await ref.read(authNotifierProvider.notifier).logout();
    await PrefsService.clearAll();

    if (mounted) context.go('/login');
  }

  // ----------------------------------------------------------
  // EMAIL VERIFY — CLASS LEVEL
  // ----------------------------------------------------------
  Future<void> _verifyEmail(String email) async {
    final userNotifier = ref.read(userNotifierProvider.notifier);

    await userNotifier.sendEmailVerification(email);

    final otp = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (_) => EmailVerificationDialog(email: email),
    );

    if (otp == null || otp.isEmpty) return;

    try {
      await userNotifier.verifyEmailOtp(otp);
      final refreshedUser = ref.read(userNotifierProvider).user;

      if (refreshedUser?.isEmailVerified == true) {
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

  // ----------------------------------------------------------
  // INIT
  // ----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userNotifierProvider.notifier).loadUser(forceRefresh: false);
    });
  }

  // ----------------------------------------------------------
  // BUILD — ARTIK SADECE UI, NAVIGATION YOK
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final user = userState.user;
    final saving = ref.watch(savingProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesabım'),
        centerTitle: true,
        backgroundColor: AppColors.primaryDarkGreen,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.read(userNotifierProvider.notifier).loadUser(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          child: Column(
            children: [
              const SizedBox(height: 8),

              const CircleAvatar(
                radius: 35,
                backgroundColor: Color(0xFFE6F4EA),
                child: Icon(Icons.person, size: 48, color: AppColors.primaryDarkGreen),
              ),
              const SizedBox(height: 8),

              Text(
                "${user.name ?? ''} ${user.surname ?? ''}".trim().isEmpty
                    ? "Profil Bilgileri Eksik"
                    : "${user.name ?? ''} ${user.surname ?? ''}",
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 14),

              // ---------------- PROFILE ----------------
              _buildCard(
                title: "Profil",
                onEdit: () => context.push(
                  '/profileDetail',
                  extra: {'fromOnboarding': false},
                ),
                children: [
                  InfoRowWidget(
                    icon: Icons.person_outline,
                    label: "Ad Soyad",
                    value: "${user.name ?? ''} ${user.surname ?? ''}".trim().isEmpty
                        ? "-"
                        : "${user.name ?? ''} ${user.surname ?? ''}",
                  ),
                  const SizedBox(height: 6),
                  InfoRowWidget(
                    icon: Icons.mail_outline,
                    label: "E-posta",
                    value: user.email ?? "-",
                    isVerified: user.isEmailVerified,
                    onVerify: user.email != null && !user.isEmailVerified
                        ? () => _verifyEmail(user.email!)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  InfoRowWidget(
                    icon: Icons.phone_outlined,
                    label: "Telefon",
                    value: user.phoneNumber,
                    isVerified: user.isPhoneVerified,
                  ),
                  const SizedBox(height: 6),
                  InfoRowWidget(
                    icon: Icons.person_2_outlined,
                    label: "Cinsiyet",
                    value: user.gender ?? "-",
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ---------------- SAVING CARD ----------------
              _buildSavingCard(saving),

              const SizedBox(height: 10),

              // ---------------- SETTINGS ----------------
              _buildCard(
                title: "Hesap Ayarları",
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: Colors.black54),
                    title: const Text("Yasal Bilgiler"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.email_outlined, color: Colors.black54),
                    title: const Text("Bize Ulaşın"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/support'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined, color: Colors.black54),
                    title: const Text("Oturumu Kapat"),
                    onTap: _logout,
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_off_outlined, color: Colors.red),
                    title: const Text("Hesabımı Kapat",
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

  // ----------------------------------------------------------
  // CARD UI
  // ----------------------------------------------------------
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

  // ----------------------------------------------------------
  // SAVING CARD
  // ----------------------------------------------------------
  Widget _buildSavingCard(SavingModel saving) {
    return _buildCard(
      title: "Kurtardığın Paketler & Kazançların",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatBox(
              icon: Icons.shopping_bag_outlined,
              value: "${saving.packagesSaved}",
              label: "Paket Kurtardın",
            ),
            _StatBox(
              icon: Icons.savings_outlined,
              value: "${saving.moneySaved.toStringAsFixed(0)} TL",
              label: "Tasarruf Ettin",
            ),
            _StatBox(
              icon: Icons.eco_outlined,
              value: "${saving.carbonSavedKg.toStringAsFixed(1)} kg",
              label: "CO₂ Önledin",
            ),
          ],
        ),
        const Divider(height: 22),
        ListTile(
          leading:
          const Icon(Icons.history_outlined, color: Colors.black54),
          title: const Text("Geçmiş Siparişlerim"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/order-history'),
        ),
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
            color: AppColors.primaryDarkGreen.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 26, color: AppColors.primaryDarkGreen),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.primaryDarkGreen,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
          ),
        )
      ],
    );
  }
}
