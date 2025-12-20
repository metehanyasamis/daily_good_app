import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
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
  bool _initialized = false;
  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // USER DATA POPULATE
  // ---------------------------------------------------------------
  void _populate(UserState state) {
    final u = state.user!;
    _nameController.text = u.firstName ?? "";
    _surnameController.text = u.lastName ?? "";
    _emailController.text = u.email ?? "";
    _selectedBirthDate =
    u.birthDate != null ? DateTime.tryParse(u.birthDate!) : null;
  }

  // ---------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------
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
            onDateTimeChanged: (v) => setState(() => _selectedBirthDate = v),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // SAVE
  // ---------------------------------------------------------------
  Future<void> _save(UserNotifier notifier, UserState state) async {
    final u = state.user!;
    final first = _nameController.text.trim();
    final last = _surnameController.text.trim();
    final email = _emailController.text.trim();

    if (first.isEmpty || last.isEmpty || email.isEmpty) {
      return _showError("Lütfen Zorunlu Alanları Doldurunuz.");
    }

    final updated = u.copyWith(
      firstName: first,
      lastName: last,
      email: email,
      birthDate: _selectedBirthDate != null
          ? _selectedBirthDate!.toIso8601String().split("T").first
          : null,
    );

    try {
      await notifier.updateUser(updated);
      await ref.read(appStateProvider.notifier).setHasSeenProfileDetails(true);
    } catch (e) {
      _showError("Kayıt hatası: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ---------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);

    if (state.status == UserStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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

                _label("Ad *"),
                _input(_nameController),
                const SizedBox(height: 20),

                _label("Soyad *"),
                _input(_surnameController),
                const SizedBox(height: 20),

                _label("Telefon"),
                _readonlyPhone(user?.phone ?? ""),
                const SizedBox(height: 20),

                _label("E-posta *"),
                _input(_emailController),
                const SizedBox(height: 20),

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

  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------
  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
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
        hintText: value,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        suffixIcon: const Icon(Icons.lock, color: Colors.grey),
      ),
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
            const Icon(Icons.calendar_month, color: AppColors.primaryDarkGreen),
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
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return const Row(
      children: [
        SizedBox(width: 40),
        Expanded(
          child: Text(
            "Profil Detayları",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: 40),
      ],
    );
  }
}
