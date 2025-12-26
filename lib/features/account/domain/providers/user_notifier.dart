import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../states/user_state.dart';
import '../../../../core/data/prefs_service.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref: ref,
    repository: ref.read(userRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final UserRepository repository;
  final AuthRepository authRepository;

  UserNotifier({
    required this.ref,
    required this.repository,
    required this.authRepository,
  }) : super(const UserState.initial());

  // Giriş sonrası veya me sonrası kullanıcıyı kaydet
  Future<void> saveUser(UserModel user) async {
    print("🛠 [DEBUG-SAVE] saveUser çağrıldı!");
    print("🛠 [DEBUG-SAVE] Gelen Token: ${user.token}");
    print("🛠 [DEBUG-SAVE] Gelen Phone: ${user.phone}");

    if (user.token != null && user.token!.isNotEmpty) {
      await PrefsService.saveToken(user.token!);
      // Kaydettikten hemen sonra geri okumayı dene, bakalım gerçekten yazıyor mu?
      final check = await PrefsService.getToken();
      print("🛠 [DEBUG-SAVE] Prefs'e yazılan token kontrolü: $check");
    } else {
      print("🚨 [DEBUG-SAVE] DİKKAT: Token boş geldiği için Prefs'e hiçbir şey yazılmadı!");
    }

    state = UserState.ready(user);
  }

  // Yeni kullanıcıyı locale kaydet (Token henüz yokken)
  void saveUserLocally(UserModel user) {
    state = UserState.ready(user);
    debugPrint("📌 [USER] saveUserLocally → ${user.phone}");
  }

  // Çıkış yap
  void clearUser() {
    PrefsService.clearAll();
    state = const UserState.initial();
    debugPrint("🧹 [USER] clearUser");
  }

  // Kullanıcı bilgilerini backend'den tazele
  Future<void> loadUser({bool forceRefresh = true}) async {
    try {
      state = const UserState.loading();
      final user = await repository.fetchUser();
      state = UserState.ready(user);
      debugPrint("🔄 [USER] loadUser → OK");
    } catch (e) {
      state = UserState.error(e.toString());
      debugPrint("❌ [USER] loadUser ERROR → $e");
    }
  }

  // ------------------------------------------------------------------
  // TEK VE ANA GÜNCELLEME METODU (Düzeltilmiş Versiyon)
  // ------------------------------------------------------------------
  Future<void> updateUser(UserModel updated) async {
    final previousUser = state.user;
    final bool isNewUser = ref.read(appStateProvider).isNewUser;

    print("🚀 [NOTIFIER] Güncelleme Başladı. Yeni Kullanıcı: $isNewUser");
    print("📅 [NOTIFIER] Gönderilen Doğum Tarihi: ${updated.birthDate}");

    try {
      state = state.copyWith(status: UserStatus.loading);
      UserModel savedUser;

      if (isNewUser) {
        savedUser = await authRepository.registerUser(updated);
      } else {
        savedUser = await repository.updateUser(updated);
      }

      print("✅ [NOTIFIER] Backend'den Gelen Tarih: ${savedUser.birthDate}");
      state = UserState.ready(savedUser);
    } catch (e) {
      print("❌ [NOTIFIER] HATA: $e");
      state = previousUser != null ? UserState.ready(previousUser) : const UserState.initial();
      rethrow;
    }
  }

  // ------------------------------------------------------------------
  // 📧 E-POSTA DEĞİŞTİRME AKIŞI (Yeni Eklenenler)
  // ------------------------------------------------------------------

  // 1. OTP Kodu Gönder (Eksik olan metot buydu)
  Future<void> sendEmailChangeOtp(String newEmail) async {
    try {
      print("🚀 [NOTIFIER] Email Change OTP İstendi: $newEmail");
      await repository.sendEmailChangeOtp(newEmail);
    } catch (e) {
      print("❌ [NOTIFIER] sendEmailChangeOtp Hata: $e");
      rethrow;
    }
  }

  // 2. OTP Kodu Doğrula (E-posta değişimini tamamlar)
  Future<bool> verifyEmailChangeOtp(String email, String code) async {
    try {
      print("🔑 [NOTIFIER] Email Change OTP Doğrulanıyor: $code");
      // Repository'den gelen güncel kullanıcı modelini alıyoruz
      final updatedUser = await repository.verifyEmailChangeOtp(email, code);

      // State'i yeni kullanıcı bilgileriyle güncelle
      state = UserState.ready(updatedUser);
      print("✅ [NOTIFIER] Email Değişimi Başarılı!");
      return true;
    } catch (e) {
      print("❌ [NOTIFIER] verifyEmailChangeOtp Hata: $e");
      return false;
    }
  }

  // Email OTP işlemleri
  Future<void> sendEmailVerification(String email) async {
    await repository.sendEmailVerification(email);
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      await repository.verifyEmailOtpCode(email, otp);
      final updatedUser = await repository.fetchUser();
      state = UserState.ready(updatedUser);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Diğer işlemler
  Future<void> updatePhone(String phone) async {
    final user = await repository.updatePhoneNumber(phone);
    state = UserState.ready(user);
  }

  Future<void> deleteUserAccount() async {
    debugPrint("🚀 [NOTIFIER] Fonksiyon tetiklendi!");
    try {
      await repository.deleteAccount();
      debugPrint("✅ [NOTIFIER] Repo bitti.");
    } catch (e) {
      debugPrint("🚨 [NOTIFIER] Hata: $e");
      rethrow;
    }
  }
}