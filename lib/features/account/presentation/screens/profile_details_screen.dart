import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/email_verification_dialog.dart';
import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../domain/providers/user_notifier.dart';
import '../../domain/states/user_state.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  final bool fromOnboarding;
  const ProfileDetailsScreen({super.key, this.fromOnboarding = false});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _initialized = false;
  bool _isEmailValid = false;

// ProfileDetailsScreen.dart (initState)

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(userNotifierProvider.notifier);
      final current = ref.read(userNotifierProvider).user;

      if (current == null) {
        // YENİ KULLANICI İÇİN: /me ÇAĞRMAK YERİNE,
        // EĞER SADECE /me hatası alıyorsanız, bu bloktaki kodları çıkarın:
        /*
        try {
          await notifier.loadUser();
        } catch (e) {
          debugPrint("❌ loadUser hata: $e");
        }
        */

        // VEYA EĞER YENİ KULLANICI İÇİN HATA ALIYORSANIZ,
        // YENİ KULLANICILARIN loadUser() fonksiyonunu atlaması gerekir.
        // Ama bunu yapmak için Login/OTP sırasında bir şekilde "yeni kullanıcı"
        // bilgisini UserNotifier'a aktarmalısınız.

        // Şimdilik, sadece hatanın kaynağını devre dışı bırakalım:
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Kullanıcı bilgilerini UI alanlarına doldur
  // ---------------------------------------------------------------------------
  void _populate(UserState state) {
    final u = state.user!;
    _nameController.text = u.firstName ?? "";
    _surnameController.text = u.lastName ?? "";
    _emailController.text = u.email ?? "";
    _selectedBirthDate =
    u.birthDate != null ? DateTime.tryParse(u.birthDate!) : null;
  }

  // ---------------------------------------------------------------------------
  // Doğum Tarihi
  // ---------------------------------------------------------------------------
  Future<void> _pickDate() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                "Doğum Tarihini Seç",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedBirthDate ?? DateTime.now(),
                  maximumDate: DateTime.now(),
                  minimumYear: 1950,
                  onDateTimeChanged: (value) {
                    setState(() => _selectedBirthDate = value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // EMAIL VALIDATION
  // ---------------------------------------------------------------------------
  void _validateEmail() {
    final text = _emailController.text.trim();
    final ok =
        text.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text);

    if (_isEmailValid != ok) {
      setState(() => _isEmailValid = ok);
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE
  // ---------------------------------------------------------------------------
  Future<void> _save(UserNotifier notifier, UserState state) async {
    final u = state.user!;
    final first = _nameController.text.trim();
    final last = _surnameController.text.trim();

    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen ad ve soyad alanlarını doldurunuz."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final updated = u.copyWith(
      firstName: first,
      lastName: last,
      email: _emailController.text.trim(),
      birthDate: _selectedBirthDate != null
          ? _selectedBirthDate!.toIso8601String().split("T").first
          : null,
    );

    await notifier.updateUser(updated);
    await PrefsService.setHasSeenProfileDetails(true);

    final app = ref.read(appStateProvider);

    if (!mounted) return;

    if (!app.hasSelectedLocation) {
      context.go("/locationInfo");
    } else {
      context.go("/home");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profil bilgileri kaydedildi."),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);

    if (state.status == UserStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.status == UserStatus.error) {
      return Scaffold(
        body: Center(child: Text("Bir hata oluştu: ${state.errorMessage}")),
      );
    }

    // İlk kez açılıyorsa user bilgilerini doldur
    if (!_initialized && state.user != null) {
      _populate(state);
      _initialized = true;
    }

    final user = state.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 24),

                // ---------------- AD ----------------
                _label("Ad *"),
                _input(_nameController),
                const SizedBox(height: 20),

                // ---------------- SOYAD ----------------
                _label("Soyad *"),
                _input(_surnameController),
                const SizedBox(height: 20),

                // ---------------- TELEFON (readonly) ----------------
                _label("Telefon"),
                _readonlyBox(user?.phone ?? ""),
                const SizedBox(height: 20),

                // ---------------- EMAIL ----------------
                _label("E-posta (opsiyonel)"),
                _emailField(user, notifier),
                const SizedBox(height: 20),

                // ---------------- DOGUM TARIHI ----------------
                _label("Doğum Tarihi (opsiyonel)"),
                _birthDateTile(),
                const SizedBox(height: 32),

                // ---------------- KAYDET ----------------
                _saveButton(() => _save(notifier, state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widget Helpers
  // ---------------------------------------------------------------------------
  Widget _label(String text) {
    return Text(text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: AppColors.textPrimary));
  }

  Widget _input(TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }

  Widget _readonlyBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _emailField(user, UserNotifier notifier) {
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final verified = user?.isEmailVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => _validateEmail(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        const SizedBox(height: 6),

        if (hasEmail)
          Row(
            children: [
              Icon(
                verified ? Icons.check_circle : Icons.info_outline,
                color: verified ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                verified ? "Doğrulandı" : "Doğrulanmadı",
                style: TextStyle(
                    fontSize: 13, color: verified ? Colors.green : Colors.orange),
              ),
              if (!verified && _isEmailValid)
                TextButton(
                  onPressed: () async {
                    await _startEmailVerification(
                        _emailController.text.trim(), notifier);
                  },
                  child: const Text(
                    "Doğrula",
                    style: TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _startEmailVerification(String email, UserNotifier notifier) async {
    await notifier.sendEmailVerification(email);

    final otp = await showDialog<String>(
      context: context,
      builder: (_) => EmailVerificationDialog(email: email),
    );

    if (otp == null || otp.isEmpty) return;

    try {
      await notifier.verifyEmailOtp(otp);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-posta doğrulandı")),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kod geçersiz")),
      );
    }
  }


  Widget _birthDateTile() {
    final text = _selectedBirthDate != null
        ? "${_selectedBirthDate!.day}.${_selectedBirthDate!.month}.${_selectedBirthDate!.year}"
        : "Seçilmedi";

    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Text(text, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.calendar_month,
                color: AppColors.primaryDarkGreen),
          ],
        ),
      ),
    );
  }

  Widget _saveButton(VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          gradient: const LinearGradient(
            colors: [
              AppColors.primaryDarkGreen,
              AppColors.primaryLightGreen,
            ],
          ),
        ),
        child: const Text(
          "Kaydet",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Profil Detayları",
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 36),
      ],
    );
  }
}
