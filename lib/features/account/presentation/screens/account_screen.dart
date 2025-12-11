import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/email_verification_dialog.dart';
import '../../../../core/widgets/info_row_widget.dart';

import '../../../auth/domain/providers/auth_notifier.dart';
import '../../../saving/model/saving_model.dart';
import '../../../saving/providers/saving_provider.dart';
import '../../domain/providers/user_notifier.dart';
import '../../domain/states/user_state.dart';

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




  // -------------------------------------------------------------
  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text('Hesabınızı kalıcı olarak silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Evet, Sil'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final userNotifier = ref.read(userNotifierProvider.notifier);

    await userNotifier.deleteUserAccount();
    await ref.read(authNotifierProvider.notifier).logout();
    await PrefsService.clearAll();

    if (mounted) context.go('/login');
  }

  // -------------------------------------------------------------
  Future<void> _verifyEmail(String email) async {
    final notifier = ref.read(userNotifierProvider.notifier);

    await notifier.sendEmailVerification(email);

    final otp = await showDialog<String>(
      context: context,
      builder: (_) => EmailVerificationDialog(email: email),
    );

    if (otp == null || otp.isEmpty) return;

    try {
      await notifier.verifyEmailOtp(email, otp);

      final refreshedUser = ref.read(userNotifierProvider).user;

      if (refreshedUser?.isEmailVerified == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("E-posta doğrulandı")));
      }
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Kod geçersiz')));
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

// 1) LOADING
    if (userState.status == UserStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

// 2) ERROR
    if (userState.status == UserStatus.error) {
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

// 3) SUCCESS
    final user = userState.user;
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
                        ? () => _verifyEmail(user.email!)
                        : null,
                  ),
                  const SizedBox(height: 8),
                  InfoRowWidget(
                    icon: Icons.phone_android,
                    label: "Telefon",
                    value: user.phone,
                    isVerified: user.isPhoneVerified,
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
              _buildSavingCard(saving),

              const SizedBox(height: 12),

              // -------------------------------------------------- SETTINGS
              _buildCard(
                title: "Hesap Ayarları",
                children: [
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text("Yasal Bilgiler"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: const Text("Bize Ulaşın"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/support'),
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
  Widget _buildSavingCard(SavingModel saving) {
    return _buildCard(
      title: "Kurtardığın Paketler & Kazançların",
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatBox(
              icon: Icons.local_mall_outlined,
              value: "${saving.packagesSaved}",
              label: "Paket",
            ),
            _StatBox(
              icon: Icons.savings,
              value: "${saving.moneySaved.toStringAsFixed(0)} TL",
              label: "Tasarruf",
            ),
            _StatBox(
              icon: Icons.eco_outlined,
              value: "${saving.carbonSavedKg.toStringAsFixed(1)} kg",
              label: "CO₂",
            ),
          ],
        ),
        const Divider(height: 24),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text("Geçmiş Siparişler"),
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
