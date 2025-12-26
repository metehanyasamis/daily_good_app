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
  // TEK VE ANA GÜNCELLEME METODU
  // ------------------------------------------------------------------
// ------------------------------------------------------------------
  // TEK VE ANA GÜNCELLEME METODU (Düzeltilmiş Versiyon)
  // ------------------------------------------------------------------
  Future<void> updateUser(UserModel updated) async {
    print("🔎 [CHECK] Notifier'a gelen email: '${updated.email}'"); // Bunu kontrol et!
    print("🔎 [CHECK] Notifier'a gelen phone: '${updated.phone}'"); // Bunu kontrol et!


    final previousUser = state.user;

    // 1. HATA DÜZELTME: appState üzerinden newUser kontrolü
    // Eğer AppState modelinin içinde 'newUser' diye bir alan varsa bu şekilde okunur:
    final bool isNewUser = ref.read(appStateProvider).isNewUser;

    print("🚀 [NOTIFIER] İşlem başladı. Yeni kullanıcı mı?: $isNewUser");

    try {
      // UserState içindeki copyWith ile status'u loading yapıyoruz
      state = state.copyWith(status: UserStatus.loading);

      UserModel savedUser;

      if (isNewUser) {
        // 1. Yeni Kayıt (AuthRepository üzerinden)
        print("🎯 [NOTIFIER] AuthRepository.registerUser çağrılıyor...");
        savedUser = await authRepository.registerUser(updated);

      } else {
        // 2. Mevcut Güncelleme (UserRepository üzerinden)
        print("📝 [NOTIFIER] UserRepository.updateUser çağrılıyor...");
        savedUser = await repository.updateUser(updated);
      }

      print("✅ [NOTIFIER] İşlem Başarılı: ${savedUser.firstName}");
      // İşlem bitince User'ı state'e "ready" olarak koyuyoruz
      state = UserState.ready(savedUser);

    } catch (e) {
      print("❌ [NOTIFIER] HATA YAKALANDI: $e");

      // 2. HATA DÜZELTME: Catch bloğunda state ataması
      if (previousUser != null) {
        // Eğer eski bir kullanıcı verisi varsa onu geri yükle ve status'u error/ready yap
        state = UserState.ready(previousUser);
      } else {
        // Eğer hiç veri yoksa, UserState.initial() gibi bir başlangıç state'i ver
        // 'state = UserStatus.initial' YANLIŞTI, doğrusu aşağıda:
        state = const UserState.initial();
      }
      rethrow;
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
    await repository.deleteAccount();
    clearUser();
  }
}