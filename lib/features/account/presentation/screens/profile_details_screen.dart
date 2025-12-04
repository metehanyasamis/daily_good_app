import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/email_verification_dialog.dart';
import '../../domain/providers/user_notifier.dart';
import '../../domain/states/user_state.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  ConsumerState<ProfileDetailsScreen> createState() =>
      _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends ConsumerState<ProfileDetailsScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEmailValid = false;
  DateTime? _selectedBirthDate;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Kullanıcı formu doldur
  // ----------------------------------------------------------
  void _populate(UserState state) {
    final u = state.user!;
    _nameController.text = u.firstName ?? "";
    _surnameController.text = u.lastName ?? "";
    _emailController.text = u.email ?? "";

    _selectedBirthDate =
    u.birthDate != null ? DateTime.tryParse(u.birthDate!) : null;
  }

  // ----------------------------------------------------------
  // EMAIL VALIDATION
  // ----------------------------------------------------------
  void _validateEmail() {
    final text = _emailController.text.trim();
    final ok =
        text.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text);

    if (_isEmailValid != ok) {
      setState(() => _isEmailValid = ok);
    }
  }

  // ----------------------------------------------------------
  // EMAIL DOĞRULAMA
  // ----------------------------------------------------------
  Future<void> _startEmailVerification(
      String email, UserNotifier notifier) async {
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

  // ----------------------------------------------------------
  // Tarih seçimi
  // ----------------------------------------------------------
  Future<void> _pickDate() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) {
        return SizedBox(
          height: 300,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedBirthDate ?? DateTime(2000),
            maximumDate: DateTime.now(),
            minimumYear: 1950,
            onDateTimeChanged: (v) {
              setState(() => _selectedBirthDate = v);
            },
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // SAVE (Redirect yönlendirecek)
  // ----------------------------------------------------------
  Future<void> _save(UserNotifier notifier, UserState state) async {
    if (!mounted) return; // Erken çıkış kontrolü

    debugPrint("💾 [PROFILE] _save metodu çağrıldı.");

    final u = state.user!;
    final first = _nameController.text.trim();
    final last = _surnameController.text.trim();

    // Zorunlu alan kontrolü
    if (first.isEmpty || last.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ad ve Soyad zorunludur.")),
      );
      return;
    }

    // UserModel'i form verileriyle güncelle
    final updated = u.copyWith(
      firstName: first,
      lastName: last,
      email: _emailController.text.trim(),
      birthDate: _selectedBirthDate != null
          ? _selectedBirthDate!.toIso8601String().split("T").first
          : null,
      // Lokasyon ve FCM token gibi alanlar buraya eklenebilir.
    );

    try {
      // 1. API Çağrısı ve Yerel Kullanıcı Güncellemesi
      // AuthRepository'deki registerUser (veya updateUser) metodu çağrılır.
      await notifier.updateUser(updated);

      // --- YÖNLENDİRME KRİTİK ADIMLARI ---

      // 2. hasSeenProfileDetails bayrağını ayarla
      // Bu adım, Profil Detayları ekranının bir daha gösterilmesini engeller.
      final appStateNotifier = ref.read(appStateProvider.notifier);
      await appStateNotifier.setHasSeenProfileDetails(true);

      // 3. isNewUser bayrağını false yap
      // Bu, GoRouter'a "Kullanıcı kaydını tamamladı, artık sıradaki adıma (Onboarding) geçebiliriz" sinyalini verir.
      // Loglarda isNewUser=true görüldüğü için bu ekleme şarttır.
      await appStateNotifier.setIsNewUser(false);

      // --- BAŞARI VE YÖNLENDİRME ---

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil başarıyla kaydedildi.")),
      );

      // GoRouter'ın redirect mantığını tetiklemek için bir sonraki hedefe gitmeye zorlama.
      // isNewUser=false ve hasSeenOnboarding=false olduğu için, GoRouter /onboarding'e yönlendirecektir.
      ref.read(appRouterProvider).go('/splash');

    } catch (e) {
      if (!mounted) return;

      debugPrint("❌ [PROFILE] Kayıt/Güncelleme Hatası: $e");
      // Hatanın detayını gösteren bir SnackBar gösterilebilir (örneğin e.toString() gibi)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profil kaydı/güncellemesi başarısız oldu. Lütfen tekrar deneyin."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // ----------------------------------------------------------
  // UI
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);

    if (state.status == UserStatus.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.status == UserStatus.error) {
      return Scaffold(
        body: Center(child: Text("Bir hata oluştu: ${state.errorMessage}")),
      );
    }

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
                _header(),

                const SizedBox(height: 24),

                // AD
                _label("Ad *"),
                _input(_nameController),
                const SizedBox(height: 20),

                // SOYAD
                _label("Soyad *"),
                _input(_surnameController),
                const SizedBox(height: 20),

                // TELEFON
                _label("Telefon"),
                _readonlyPhone(user?.phone ?? ""),
                const SizedBox(height: 20),

                // EMAIL
                _label("E-posta (opsiyonel)"),
                _emailField(user, notifier),
                const SizedBox(height: 20),

                // Doğum tarihi
                _label("Doğum Tarihi (opsiyonel)"),
                _birthDateTile(),
                const SizedBox(height: 30),

                _saveButton(() => _save(notifier, state)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // WIDGET HELPERS
  // ----------------------------------------------------------
  Widget _label(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _input(TextEditingController c) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _readonlyPhone(String value) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        suffixIcon: const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }

  // ----------------------------------------------------------
  // EMAIL FIELD (Doğrulama içeren)
  // ----------------------------------------------------------
  Widget _emailField(user, UserNotifier notifier) {
    final verified = user?.isEmailVerified ?? false;
    final hasEmail = _emailController.text.trim().isNotEmpty;

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
                  fontSize: 14,
                  color: verified ? Colors.green : Colors.orange,
                ),
              ),

              // Doğrulama butonu
              if (!verified && _isEmailValid)
                TextButton(
                  onPressed: () async {
                    await _startEmailVerification(
                      _emailController.text.trim(),
                      notifier,
                    );
                  },
                  child: const Text(
                    "Doğrula",
                    style: TextStyle(
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
            ],
          ),
      ],
    );
  }

  Widget _birthDateTile() {
    final text = _selectedBirthDate == null
        ? "Seçilmedi"
        : "${_selectedBirthDate!.day}.${_selectedBirthDate!.month}.${_selectedBirthDate!.year}";

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
            Text(text),
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

  Widget _header() {
    return Row(
      children: const [
        SizedBox(width: 40),
        Expanded(
          child: Text(
            "Profil Detayları",
            textAlign: TextAlign.center,
            style:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }
}
