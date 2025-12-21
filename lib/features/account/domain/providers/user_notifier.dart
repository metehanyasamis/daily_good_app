import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../states/user_state.dart';
import '../../../../core/data/prefs_service.dart';

final userNotifierProvider =
StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref: ref,
    repository: ref.read(userRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider), // 💡 AuthRepo eklendi
  );
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final UserRepository repository;
  final AuthRepository authRepository; // 💡 AuthRepo eklendi

  UserNotifier({
    required this.ref,
    required this.repository,
    required this.authRepository, // 💡 AuthRepo eklendi
  }) : super(const UserState.initial());

  // ------------------------------------------------------------------
  // EXISTING USER SAVE (token var → login veya /me sonrası)
  // ------------------------------------------------------------------
  Future<void> saveUser(UserModel user) async {
    if (user.token != null && user.token!.isNotEmpty) {
      await PrefsService.saveToken(user.token!);
    }

    state = UserState.ready(user);

    print("📌 [USER] saveUser → ${user.phone}");
  }

  // ------------------------------------------------------------------
  // NEW USER SAVE — token yok ama user objesi lazım
  // ------------------------------------------------------------------
  void saveUserLocally(UserModel user) {
    state = UserState.ready(user); // 🚀 redirect çalışması için KRİTİK

    print("📌 [USER] saveUserLocally → ${user.phone}");
  }

  // ------------------------------------------------------------------
  // LOGOUT — her şeyi temizle
  // ------------------------------------------------------------------
  void clearUser() {
    PrefsService.clearAll();
    state = const UserState.initial();

    print("🧹 [USER] clearUser");
  }

  // ------------------------------------------------------------------
  // /me çağır — uygulama açılışında token varsa
  // ------------------------------------------------------------------
  Future<void> loadUser({bool forceRefresh = true}) async {
    try {
      state = const UserState.loading();

      final user = await repository.fetchUser();

      state = UserState.ready(user);

      print("🔄 [USER] loadUser → OK");
    } catch (e) {
      state = UserState.error(e.toString());
      print("❌ [USER] loadUser ERROR → $e");
    }
  }

// ------------------------------------------------------------------
  // PROFIL UPDATE VEYA REGISTER (ANA REFACTOR BURASI)
  // ------------------------------------------------------------------
  Future<void> updateUser(UserModel updated) async {
    final previousUser = state.user; // Mevcut halini yedekle

    try {
      state = state.copyWith(status: UserStatus.loading);

      // 1. Backend'e gönder
      final savedUser = await repository.updateUser(updated);

      // 2. 🔥 HİBRİT GÜNCELLEME:
      // Backend her şeyi dönmeyebilir. Backend'den gelen veriyi (savedUser),
      // bizim gönderdiğimiz verideki (updated) sabitlerle birleştirelim.
      final finalUser = savedUser.copyWith(
        // Eğer backend email'i boş dönerse, eskisini koru
        email: (savedUser.email == null || savedUser.email!.isEmpty)
            ? updated.email
            : savedUser.email,

        // Eğer backend birthDate'i null dönerse, bizim seçtiğimizi koru
        birthDate: savedUser.birthDate ?? updated.birthDate,

        // Token ve doğrulama durumlarını da mutlaka koru
        token: savedUser.token ?? previousUser?.token,
        isEmailVerified: savedUser.isEmailVerified,
        isPhoneVerified: savedUser.isPhoneVerified,
      );

      state = UserState.ready(finalUser);
      debugPrint("✔️ Profil hibrit olarak güncellendi.");

    } catch (e) {
      debugPrint("❌ Update Error: $e");
      if (previousUser != null) {
        state = UserState.ready(previousUser);
      }
      rethrow;
    }
  }


// ------------------------------------------------------------------
// EMAIL OTP GÖNDER
// ------------------------------------------------------------------
  Future<void> sendEmailVerification(String email) async {
    print("📧 [USER] Email OTP SEND → $email");
    await repository.sendEmailVerification(email);
  }

// ------------------------------------------------------------------
// EMAIL OTP DOĞRULA
// ------------------------------------------------------------------
  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      print("📧 [USER] Email OTP VERIFY → email=$email, code=$otp");

      // 1. Doğrulamayı yap
      await repository.verifyEmailOtpCode(email, otp);

      // 2. 🔥 EN GARANTİ YOL: Backend'den en güncel profil bilgilerini tekrar çek
      // Böylece email_verified_at kesinlikle dolu gelir.
      final updatedUser = await repository.fetchUser();

      // 3. State'i yeni gelen veriyle güncelle
      state = UserState.ready(updatedUser);

      print("📧 [USER] Email OTP VERIFIED & STATE UPDATED → ${updatedUser.email}");
      return true;
    } catch (e) {
      print("❌ [USER] Email OTP VERIFY ERROR → $e");
      // Hata durumunda state'i bozma, sadece false dön ki UI hata (kırmızı) göstersin
      return false;
    }
  }


  // ------------------------------------------------------------------
  // TELEFON GÜNCELLE
  // ------------------------------------------------------------------
  Future<void> updatePhone(String phone) async {
    final user = await repository.updatePhoneNumber(phone);
    state = UserState.ready(user);

    print("📞 [USER] updatePhone → $phone");
  }

  // ------------------------------------------------------------------
  // HESAP SİL
  // ------------------------------------------------------------------
  Future<void> deleteUserAccount() async {
    await repository.deleteAccount();
    clearUser();

    print("🗑 [USER] deleteUserAccount");
  }
}
