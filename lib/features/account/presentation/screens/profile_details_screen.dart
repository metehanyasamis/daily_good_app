import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/prefs_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/email_verification_dialog.dart';
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
  String? _selectedGender;
  bool _isEmailFieldValid = false;
  bool _initialized = false;
  bool _snackbarShown = false; // ✅ flag artık state seviyesinde

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
          debugPrint('❌ loadUser hatası: $e');
        }
      }
    });
  }

  void _populateFields(user) {
    _nameController.text = user.name ?? '';
    _surnameController.text = user.surname ?? '';
    _emailController.text = user.email ?? '';
    _selectedGender = user.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final user = userState.user;
    final notifier = ref.read(userNotifierProvider.notifier);

    if (user != null && !_initialized) {
      _populateFields(user);
      _initialized = true;
    }

    if (user == null || userState.status == UserStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                _buildEmailFieldWithStatus(user, notifier),
                _buildPhoneFieldWithStatus(user),
                _buildGenderDropdown(),
                const SizedBox(height: 24),
                _buildSaveButton(notifier, user),
              ],
            ),
          ),
        ),
      ),
    );
  }

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

  Widget _buildEmailFieldWithStatus(user, UserNotifier notifier) {
    final hasEmail = _emailController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "E-posta adresi",
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _emailController.clear();
                  setState(() => _isEmailFieldValid = false);
                },
                child: const Icon(
                  Icons.edit,
                  size: 18,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onChanged: (_) => _validateEmailField(),
          ),
          const SizedBox(height: 6),
          if (hasEmail)
            Row(
              children: [
                Icon(
                  user.isEmailVerified
                      ? Icons.check_circle
                      : Icons.info_outline,
                  color: user.isEmailVerified
                      ? Colors.green
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isEmailVerified ? 'Doğrulandı' : 'Doğrulanmadı',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: user.isEmailVerified
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                if (!user.isEmailVerified && _isEmailFieldValid)
                  TextButton(
                    onPressed: () async {
                      await _startEmailVerification(
                          _emailController.text.trim(), notifier);
                      setState(() {});
                    },
                    child: const Text(
                      'Şimdi Doğrula',
                      style: TextStyle(
                        color: AppColors.primaryDarkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _validateEmailField() {
    final text = _emailController.text.trim();
    final isValid = text.isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(text);
    if (_isEmailFieldValid != isValid) {
      setState(() => _isEmailFieldValid = isValid);
    }
  }

  Future<void> _startEmailVerification(
      String email, UserNotifier notifier) async {
    await notifier.sendEmailVerification(email);

    final otpCode = await showDialog<String>(
      context: context,
      builder: (_) => EmailVerificationDialog(email: email),
    );

    if (otpCode == null || otpCode.isEmpty) return;

    try {
      await notifier.verifyEmailOtp(otpCode);
      final refreshedUser = ref.read(userNotifierProvider).user;

      if (refreshedUser != null) {
        setState(() {
          final updatedUser = refreshedUser.copyWith(
            name: _nameController.text.trim(),
            surname: _surnameController.text.trim(),
            gender: _selectedGender,
          );
          _emailController.text =
              refreshedUser.email ?? _emailController.text;
          _isEmailFieldValid = true;
          ref
              .read(userNotifierProvider.notifier)
              .updateUser(updatedUser);
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-posta doğrulandı')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kod geçersiz')),
        );
      }
    }
  }

  Widget _buildPhoneFieldWithStatus(user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text("Telefon", style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            const Icon(Icons.edit,
                size: 18, color: AppColors.primaryDarkGreen),
          ]),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(30),
            ),
            child:
            Text(user.phoneNumber, style: const TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 6),
          Row(children: [
            Icon(
              user.isPhoneVerified
                  ? Icons.check_circle
                  : Icons.info_outline,
              color: user.isPhoneVerified
                  ? Colors.green
                  : Colors.orange,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              user.isPhoneVerified ? 'Doğrulandı' : 'Doğrulanmadı',
              style: TextStyle(
                color: user.isPhoneVerified
                    ? Colors.green
                    : Colors.orange,
                fontSize: 13,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
        items: const [
          DropdownMenuItem(value: "Erkek", child: Text("Erkek")),
          DropdownMenuItem(value: "Kadın", child: Text("Kadın")),
          DropdownMenuItem(
              value: "Belirtmek istemiyorum",
              child: Text("Belirtmek istemiyorum")),
        ],
        onChanged: (v) => setState(() => _selectedGender = v),
      ),
    );
  }

  Widget _buildSaveButton(UserNotifier notifier, user) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: () async {
        if (_snackbarShown) return; // ✅ çift basmayı engelle
        _snackbarShown = true;

        final updated = user.copyWith(
          name: _nameController.text.trim(),
          surname: _surnameController.text.trim(),
          email: _emailController.text.trim(),
          gender: _selectedGender,
        );

        await notifier.updateUser(updated);
        await PrefsService.setHasSeenProfileDetails(true);

        if (!mounted) return;

        // ✅ 1. önce yönlendirme yap
        if (widget.fromOnboarding) {
          final seenOnb = await PrefsService.getHasSeenOnboarding();
          if (!seenOnb) {
            context.go('/onboarding');
          } else {
            context.go('/home');
          }
        } else {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/account');
          }
        }

        // ✅ 2. sonra 300ms sonra SnackBar göster
        Future.delayed(const Duration(milliseconds: 300), () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil bilgileri kaydedildi")),
          );
        });

        // ✅ 3. 2 sn sonra tekrar aktif hale gelsin
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
              AppColors.primaryLightGreen
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
