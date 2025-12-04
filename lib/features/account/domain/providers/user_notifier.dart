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
    debugPrint("🔄 [USER] updateUser çağrıldı. Mevcut User ID: ${updated.id}");

    try {
      state = const UserState.loading();

      // NOT: Kullanıcı ID'si ve Token'ı varsa bile, login sırasında aldığımız
      // eksik kullanıcı bilgisi nedeniyle buraya düşebilir.
      final bool isNewUser = (updated.id.isEmpty || updated.token == null);

      // 💡 DÜZELTME: user değişkenine başlangıç değeri olarak updated modelini atayın.
      // Bu, hem new/existing dallarında kullanılır hem de hata durumunu çözer.
      UserModel user = updated;

      if (isNewUser) {
        debugPrint("📌 [USER] Yeni Kullanıcı Algılandı → registerUser çağrılıyor (TEST AMAÇLI ATLANIYOR).");

        // 1. Kayıt işlemini yap (GEÇİCİ OLARAK YORUM SATIRI KALMALI)
        // user = await authRepository.registerUser(updated);

        // 2. Token'ı kaydet (GEÇİCİ OLARAK YORUM SATIRI KALMALI)
        // await saveUser(user);

        // =======================================================
        // KRİTİK GÜNCELLEMELER (Test için gerekli)
        // =======================================================
        final appStateNotifier = ref.read(appStateProvider.notifier);
        await appStateNotifier.setHasSeenProfileDetails(true);
        await appStateNotifier.setNewUser(false);
        // =======================================================

      } else {
        debugPrint("📌 [USER] Mevcut Kullanıcı Algılandı → updateUser çağrılıyor.");
        user = await repository.updateUser(updated);
      }

      state = UserState.ready(user); // Artık 'user' kesinlikle atanmıştır.

      debugPrint("📌 [USER] updateUser/registerUser → BAŞARILI");

    } catch (e) {
      state = UserState.error(e.toString());
      debugPrint("❌ [USER] updateUser/registerUser ERROR → $e");
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
  Future<UserModel> verifyEmailOtp(String otp) async {
    print("📧 [USER] Email OTP VERIFY → $otp");

    final user = await repository.verifyEmailOtpCode(otp);

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
