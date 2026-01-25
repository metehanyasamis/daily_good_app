import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../domain/providers/user_notifier.dart';
import '../../domain/states/user_state.dart';
import '../widgets/email_change_sheeet.dart';
import '../widgets/email_otp_dialog.dart';

class ProfileDetailsScreen extends ConsumerStatefulWidget {
  final bool isFromRegister;

  const ProfileDetailsScreen({super.key, this.isFromRegister = false});

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
    _selectedBirthDate = u.birthDate != null
        ? DateTime.tryParse(u.birthDate!)
        : null;
  }

  // --- SAVE METODU ---
  Future<void> _save(UserNotifier notifier, UserState state) async {
    String? formattedDate;
    if (_selectedBirthDate != null) {
      formattedDate =
          "${_selectedBirthDate!.year}-"
          "${_selectedBirthDate!.month.toString().padLeft(2, '0')}-"
          "${_selectedBirthDate!.day.toString().padLeft(2, '0')}";
    }

    final userToSave = UserModel(
      id: state.user?.id ?? "",
      phone: state.user?.phone ?? "",
      firstName: _nameController.text.trim(),
      lastName: _surnameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: formattedDate,
      isEmailVerified: state.user?.isEmailVerified ?? false,
      isPhoneVerified: state.user?.isPhoneVerified ?? false,
    );

    try {
      await notifier.updateUser(userToSave);
      if (mounted) {
        Toasts.success(context, "Profil başarıyla güncellendi."); // 🎯 Tertemiz

        if (widget.isFromRegister) {
          context.go('/onboarding');
        } else {
          context.pop();
        }
      }
    } catch (e) {
      _showError(e.toString().replaceAll("Exception: ", ""));
    }
  }

  // --- E-POSTA KUTUSU (Hata buradaydı, düzeltildi) ---
  Widget _emailActionTile(UserModel user) {
    // 1. ADIM: Sadece boolean değere bak, null kontrolü yapma!
    final bool isVerified = user.isEmailVerified;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // 2. ADIM: Doğrulanmadıysa (false ise) ve kayıt ekranında değilsek çerçeve göster
        border: (!isVerified && !widget.isFromRegister)
            ? Border.all(color: Colors.orange.shade200, width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.email_outlined, color: AppColors.primaryDarkGreen),
              const SizedBox(width: 12),
              Expanded(child: Text(user.email ?? "", style: const TextStyle(fontSize: 16))),
              TextButton(
                onPressed: () => _showEmailChangeWorkflow(user.email ?? ""),
                child: const Text("Değiştir", style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          // 3. ADIM: SADECE Kayıt akışında değilsek (Hesabım sayfasındaysak) uyarıyı göster
          if (!widget.isFromRegister) ...[
            const Divider(height: 20),
            Row(
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.warning_amber_rounded,
                  size: 16,
                  color: isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  isVerified ? "E-posta Doğrulandı" : "E-posta Doğrulanmadı",
                  style: TextStyle(
                    fontSize: 13,
                    color: isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (!isVerified)
                  TextButton(
                    onPressed: () async {
                      print("1. Butona basıldı. Email: ${user.email}"); // Buton çalışıyor mu?
                      try {
                        // 1. Önce e-posta kodunu gönderiyoruz
                        print("2. sendEmailVerification çağrılıyor...");
                        await ref.read(userNotifierProvider.notifier).sendEmailVerification(user.email!);
                        print("3. Kod başarıyla gönderildi. mounted: $mounted");
                        // 2. Kod başarıyla gittiyse Modal'ı açıyoruz
                        if (mounted) {
                          print("4. Modal açılıyor...");
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Klavye açılınca ekran yukarı kaysın diye
                            backgroundColor: Colors.transparent,
                            builder: (context) => EmailOtpSheet(email: user.email!),
                          );
                        }
                      } catch (e) {
                        print("🚨 Hata oluştu: $e");
                        _showError("Kod gönderilemedi: $e");
                      }
                    },
                    child: const Text("Şimdi Doğrula",
                        style: TextStyle(color: AppColors.primaryDarkGreen, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // --- DİĞER YARDIMCILAR ---
  void _showError(String msg) {
    if (!mounted) return;

    // 🎯 Kullanıcıya hatayı hissettir
    HapticFeedback.vibrate();

    // 🚀 Merkezi Toast servisimiz
    Toasts.error(context, msg);
  }

  void _showEmailChangeWorkflow(String currentEmail) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EmailChangeSheet(currentEmail: currentEmail),
      ),
    );

    if (result == "OK" && mounted) {
      // 🎯 Başarı hissi için hafif tık
      HapticFeedback.lightImpact();
      Toasts.success(context, "E-posta başarıyla güncellendi.");
    }
  }

  Future<void> _pickDate() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Doğum Tarihi Seçin",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _selectedBirthDate ?? DateTime(2000),
                  maximumDate: DateTime.now(),
                  minimumYear: 1950,
                  onDateTimeChanged: (v) =>
                      setState(() => _selectedBirthDate = v),
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
    final state = ref.watch(userNotifierProvider);
    final notifier = ref.read(userNotifierProvider.notifier);
    final user = state.user;
    print("DEBUG: UI'daki user onay durumu: ${user?.isEmailVerified}");
    print("DEBUG: UI'daki user telefon durumu: ${user?.isPhoneVerified}");

    if (state.status == UserStatus.loading && !_initialized) {
      return Scaffold(
        body: Center(
          child: PlatformWidgets.loader(),
        ),
      );
    }

    if (!_initialized && user != null) {
      _populate(state);
      _initialized = true;
    }

    return PopScope(
      canPop: !widget.isFromRegister,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        HapticFeedback.selectionClick();
        Toasts.show(context, "Lütfen bilgilerinizi kaydedin.", isError: true);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Profil Detayları",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: widget.isFromRegister
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
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
                _label("E-posta *"),
                user != null && user.email != null && user.email!.isNotEmpty
                    ? _emailActionTile(user)
                    : _emailEditableField(),
                const SizedBox(height: 20),
                _label("Telefon"),
                _readonlyPhone(user?.phone ?? ""),
                const SizedBox(height: 20),
                _label("Doğum Tarihi"),
                _birthDateTile(),
                const SizedBox(height: 40),
                _saveButton(
                  onTap: () => _save(notifier, state),
                  isLoading: state.status == UserStatus.loading,
                  isNewUser: widget.isFromRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- DİĞER KÜÇÜK WIDGETLAR (Aynı kalıyor) ---
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    ),
  );

  Widget _input(TextEditingController c, IconData icon) => TextField(
    controller: c,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.primaryDarkGreen),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _emailEditableField() => TextField(
    controller: _emailController,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.primaryDarkGreen,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _readonlyPhone(String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(16),
    ),
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

  Widget _birthDateTile() {
    final text = _selectedBirthDate == null
        ? "Seçilmedi"
        : "${_selectedBirthDate!.day.toString().padLeft(2, '0')}.${_selectedBirthDate!.month.toString().padLeft(2, '0')}.${_selectedBirthDate!.year}";
    return InkWell(
      onTap: _pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primaryDarkGreen,
            ),
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
    required bool isNewUser,
  }) => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDarkGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: isLoading
          ? Center( // 🚀 'const' kaldırıldı
        child: SizedBox(
          height: 24,
          width: 24,
          child: PlatformWidgets.loader(
            color: Colors.white,
            strokeWidth: 2.5,
            radius: 12, // 24 width için orantılı bir iOS çark boyutu
          ),
        ),
      )
          : Text(
              isNewUser ? "Bilgilerimi Kaydet" : "Bilgilerimi Güncelle",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
    ),
  );
}
