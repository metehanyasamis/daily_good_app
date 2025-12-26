import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/user_notifier.dart';
import '../../domain/states/user_state.dart';
import '../widgets/email_change_sheeet.dart';

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

  void _populate(UserState state) {
    final u = state.user!;
    _nameController.text = u.firstName ?? "";
    _surnameController.text = u.lastName ?? "";
    _emailController.text = u.email ?? "";
    _selectedBirthDate =
    u.birthDate != null ? DateTime.tryParse(u.birthDate!) : null;
  }

  // ---------------------------------------------------------------
  // E-POSTA DEĞİŞTİRME MODAL (OTP AKIŞI)
  // ---------------------------------------------------------------
  void _showEmailChangeSheet(String currentEmail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EmailChangeBottomSheet(currentEmail: currentEmail),
    );
  }

  // ---------------------------------------------------------------
  // DATE PICKER
  // ---------------------------------------------------------------
  Future<void> _pickDate() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Doğum Tarihi Seçin",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedBirthDate ?? DateTime(2000),
                  maximumDate: DateTime.now(),
                  minimumYear: 1950,
                  onDateTimeChanged: (v) => setState(() => _selectedBirthDate = v),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // AD-SOYAD KAYDET (PUT /customer/profile)
  // ---------------------------------------------------------------
// ---------------------------------------------------------------
// PROFİL KAYDET / GÜNCELLEME MANTIĞI (Refaktör Edildi)
// ---------------------------------------------------------------
  Future<void> _save(UserNotifier notifier, UserState state) async {
    print("🔘 [UI-DEBUG] Kaydet'e basıldı.");

    final u = state.user;

    // 🛠️ Tarihi backend'in %100 anlayacağı formata getiriyoruz (YYYY-MM-DD)
    String? formattedDate;
    if (_selectedBirthDate != null) {
      formattedDate = "${_selectedBirthDate!.year}-"
          "${_selectedBirthDate!.month.toString().padLeft(2, '0')}-"
          "${_selectedBirthDate!.day.toString().padLeft(2, '0')}";
    }

    print("📝 [UI-DEBUG] Controller Email: ${_emailController.text}");
    print("📅 [UI-DEBUG] Seçili Tarih Nesnesi: $_selectedBirthDate");

    final updatedUser = u!.copyWith(
      firstName: _nameController.text.trim(),
      lastName: _surnameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: formattedDate, // Güvenli format: 1990-01-01
    );

    print("📅 [UI] Backend'e giden tarih: $formattedDate");
    print("📦 [UI-DEBUG] Notifier'a giden modeldeki tarih: ${updatedUser.birthDate}");
    print("📦 [UI-DEBUG] Notifier'a giden email: ${updatedUser.email}");

    try {
      await notifier.updateUser(updatedUser);
      print("🎉 [UI] İşlem Başarılı!");
    } catch (e) {
      print("🚩 [UI] Hata: $e");
      _showError("Hata: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);
    final user = state.user;

    // 💡 BUTON METNİ İÇİN KONTROL
    // Eğer isim boşsa ilk defa kayıt oluyordur.
    final bool isFirstTime = user?.firstName == null || user!.firstName!.isEmpty;

    if (state.status == UserStatus.loading && !_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_initialized && user != null) {
      _populate(state);
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profil Detayları",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Ad *"),
              _input(_nameController, Icons.person_outline),
              const SizedBox(height: 20),

              _label("Soyad *"),
              _input(_surnameController, Icons.person_outline),
              const SizedBox(height: 20),

              _label("E-posta"),
              // Email varsa kilitli kutu, yoksa yazılabilir kutu gösterilir
              user?.email != null && user!.email!.isNotEmpty
                  ? _emailActionTile(user!.email!)
                  : _emailEditableField(),

              const SizedBox(height: 20),

              _label("Telefon"),
              _readonlyPhone(user?.phone ?? ""),
              const SizedBox(height: 20),

              _label("Doğum Tarihi"),
              _birthDateTile(),
              const SizedBox(height: 40),

              // 💡 GÜNCELLENMİŞ BUTON
              _saveButton(
                onTap: () => _save(notifier, state),
                isLoading: state.status == UserStatus.loading,
                isNewUser: isFirstTime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
    );
  }

  Widget _input(TextEditingController c, IconData icon) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryDarkGreen),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

// 1. MOD: E-mail doluysa (Senin metodun - Kilitli/OTP'li)
  Widget _emailActionTile(String email) {
    return InkWell(
      onTap: () => _showEmailChangeSheet(email),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.email_outlined, color: AppColors.primaryDarkGreen),
            const SizedBox(width: 12),
            Text(email, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Text("Değiştir", style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

// 2. MOD: E-mail boşsa (Yeni metot - Yazılabilir/Normal Giriş)
  Widget _emailEditableField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryDarkGreen),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none
        ),
      ),
    );
  }

  Widget _readonlyPhone(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.phone_android, color: Colors.grey),
          const SizedBox(width: 12),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _birthDateTile() {
    final text = _selectedBirthDate == null
        ? "Seçilmedi"
        : "${_selectedBirthDate!.day.toString().padLeft(2, '0')}.${_selectedBirthDate!.month.toString().padLeft(2, '0')}.${_selectedBirthDate!.year}";

    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: AppColors.primaryDarkGreen),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.expand_more, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _saveButton({
    required VoidCallback onTap,
    required bool isLoading,
    required bool isNewUser
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          isNewUser ? "Bilgilerimi Kaydet" : "Bilgilerimi Güncelle",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
