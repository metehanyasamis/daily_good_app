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
  bool _isEmailFieldValid = false;
  bool _snackbarShown = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(userNotifierProvider.notifier);
      final current = ref.read(userNotifierProvider).user;

      if (current == null) {
        try {
          await notifier.loadUser();
        } catch (e) {
          debugPrint("❌ loadUser error: $e");
        }
      }
    });
  }

  void _populateFields(user) {
    _nameController.text = user.firstName ?? "";
    _surnameController.text = user.lastName ?? "";
    _emailController.text = user.email ?? "";
    _selectedBirthDate =
    user.birthDate != null ? DateTime.tryParse(user.birthDate!) : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATE PICKER (Cupertino Modern Modal)
  // ---------------------------------------------------------------------------
  Future<void> _openDatePicker() async {
    DateTime initial = _selectedBirthDate ?? DateTime(2000, 1, 1);

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
                  initialDateTime: initial,
                  maximumDate: DateTime.now(),
                  minimumYear: 1950,
                  maximumYear: DateTime.now().year,
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

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final user = userState.user;
    final notifier = ref.read(userNotifierProvider.notifier);
    final isNewUser = ref.read(userNotifierProvider).user == null;

    debugPrint("📍 build() çağrıldı - userState: $userState");
    debugPrint("👤 user = ${user?.toJson()}");
    debugPrint("🆕 isNewUser = $isNewUser");

    // Yükleniyor durumu
    if (userState.status == UserStatus.loading) {
      debugPrint("⏳ UserStatus → loading");
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Hata durumu
    if (userState.status == UserStatus.error) {
      debugPrint("❌ UserStatus → error: ${userState.errorMessage}");
      return Scaffold(
        body: Center(
          child: Text("Bir hata oluştu: ${userState.errorMessage}"),
        ),
      );
    }

    // Eğer user null değilse ve henüz alanlar doldurulmadıysa
    if (user != null && !_initialized) {
      _populateFields(user); // user! değil çünkü yukarıda null check yaptık
      _initialized = true;
    }

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
                _buildHeader(context),
                const SizedBox(height: 24),

                _buildTextField("Ad", _nameController),
                const SizedBox(height: 20),

                _buildTextField("Soyad", _surnameController),
                const SizedBox(height: 20),

                _buildEmailField(user, notifier),
                const SizedBox(height: 20),

                _buildBirthDateField(),
                const SizedBox(height: 32),

                _buildSaveButton(notifier, user),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // EMAIL FIELD + OTP STATUS
  // ---------------------------------------------------------------------------
  Widget _buildEmailField(user, UserNotifier notifier) {
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final isVerified = user?.isEmailVerified ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "E-posta Adresi",
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: (_) => _validateEmailField(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        const SizedBox(height: 6),

        if (hasEmail)
          Row(
            children: [
              Icon(
                isVerified ? Icons.check_circle : Icons.info_outline,
                color: isVerified ? Colors.green : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                isVerified ? "Doğrulandı" : "Doğrulanmadı",
                style: TextStyle(
                  color: isVerified ? Colors.green : Colors.orange,
                  fontSize: 13,
                ),
              ),

              if (!isVerified && _isEmailFieldValid)
                TextButton(
                  onPressed: () async {
                    await _startEmailVerification(
                        _emailController.text.trim(), notifier);
                    setState(() {});
                  },
                  child: const Text(
                    "Şimdi Doğrula",
                    style: TextStyle(
                      color: AppColors.primaryDarkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  void _validateEmailField() {
    final text = _emailController.text.trim();
    final valid =
        text.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text);

    if (_isEmailFieldValid != valid) {
      setState(() => _isEmailFieldValid = valid);
    }
  }

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

  // ---------------------------------------------------------------------------
  // BIRTH DATE FIELD
  // ---------------------------------------------------------------------------
  Widget _buildBirthDateField() {
    final display = _selectedBirthDate != null
        ? "${_selectedBirthDate!.day}.${_selectedBirthDate!.month}.${_selectedBirthDate!.year}"
        : "01.01.2000";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Doğum Tarihi", style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _openDatePicker,
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Text(display, style: const TextStyle(fontSize: 16)),
                const Spacer(),
                const Icon(Icons.calendar_month,
                    color: AppColors.primaryDarkGreen),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SAVE BUTTON
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton(UserNotifier notifier, user) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () async {
        if (_snackbarShown) return;
        _snackbarShown = true;

        final updated = user.copyWith(
          firstName: _nameController.text.trim(),
          lastName: _surnameController.text.trim(),
          email: _emailController.text.trim(),
          birthDate: _selectedBirthDate != null
              ? _selectedBirthDate!.toIso8601String().split("T").first
              : null,
        );

        await notifier.updateUser(updated);
        await PrefsService.setHasSeenProfileDetails(true);

        final app = ref.read(appStateProvider.notifier);


        if (!mounted) return;

        final appState = ref.read(appStateProvider);

        if (!appState.hasSelectedLocation) {
          context.go("/locationInfo");
        } else {
          context.go("/home");
        }

        Future.delayed(const Duration(milliseconds: 200), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil bilgileri kaydedildi")),
          );
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _snackbarShown = false;
        });
      },
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
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
