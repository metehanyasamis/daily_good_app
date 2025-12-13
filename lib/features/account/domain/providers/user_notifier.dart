import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_state_provider.dart';
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
  // PROFIL UPDATE
  // ------------------------------------------------------------------
// ------------------------------------------------------------------
  // PROFIL UPDATE VEYA REGISTER (ANA REFACTOR BURASI)
  // ------------------------------------------------------------------
  Future<void> updateUser(UserModel updated) async {
    debugPrint("🔄 [USER] updateUser çağrıldı. UserID: ${updated.id}");

    try {
      state = const UserState.loading();

      final bool isNewUser = updated.id.isEmpty;   // 🔥 DOĞRU KONTROL

      UserModel savedUser;

      // --------------------- NEW USER ---------------------
      if (isNewUser) {
        debugPrint("🆕 Yeni kullanıcı → registerUser çağırılıyor");

        try {
          savedUser = await authRepository.registerUser(updated);
        } on DioException catch (e) {
          final msg = e.response?.data["message"] ??
              "Kayıt olurken bir hata oluştu.";
          state = UserState.error(msg);
          return;
        }

        // Token kaydet
        if (savedUser.token != null && savedUser.token!.isNotEmpty) {
          await PrefsService.saveToken(savedUser.token!);
          await ref.read(appStateProvider.notifier).setToken(savedUser.token!);
        }

        // 🔥 AppState PROFIL Güncelleme (KRİTİK)
        final appState = ref.read(appStateProvider.notifier);
        await appState.setLoggedIn(true);
        //await appState.setIsNewUser(false);
        await appState.setHasSeenProfileDetails(true);

        state = UserState.ready(savedUser);
        return;
      }

      // --------------------- UPDATE USER ---------------------
      try {
        savedUser = await repository.updateUser(updated);
      } on DioException catch (e) {
        final msg = e.response?.data["message"] ?? "Profil güncellenemedi.";
        state = UserState.error(msg);
        return;
      }

      state = UserState.ready(savedUser);
      debugPrint("✔️ Profil güncellendi");
    }

    catch (e) {
      debugPrint("❌ Genel updateUser ERROR: $e");
      state = UserState.error(e.toString());
      return;
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
  Future<UserModel> verifyEmailOtp(String email, String otp) async {
    print("📧 [USER] Email OTP VERIFY → email=$email, code=$otp");

    final user = await repository.verifyEmailOtpCode(email, otp);

    print("📧 [USER] Email OTP VERIFIED → ${user.email}");

    state = UserState.ready(user);
    return user;
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
