import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../account/domain/providers/user_notifier.dart';
import '../../../account/data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../states/auth_state.dart';

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    repo: ref.read(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository repo;

  AuthNotifier({
    required this.ref,
    required this.repo,
  }) : super(const AuthState.initial());


  Future<void> sendOtp({required String phone, required String purpose}) async {
    state = const AuthState.loading();
    debugPrint("📡 [OTP REQUEST] $phone ($purpose)");

    try {
      // Repository artık success: false durumunda hata fırlatıyor
      final bool ok = await repo.sendOtp(phone, purpose: purpose);

      if (ok) {
        debugPrint("✅ [OTP RESPONSE] Başarılı");
        state = const AuthState.otpSent();
      } else {
        // Burası artık neredeyse hiç tetiklenmez çünkü repo hata fırlatıyor
        state = const AuthState.error("Beklenmedik bir sorun oluştu.");
      }
    } on DioException catch (e) {
      // 🔥 Backend'den gelen o gerçek mesajı yakaladığımız yer:
      final String serverMessage = e.response?.data?['message'] ?? "İşlem başarısız oldu.";

      debugPrint("❌ [BACKEND ERROR] Message: $serverMessage");

      // UI'da (LoginScreen) snackbar'da görünecek mesaj bu:
      state = AuthState.error(serverMessage);
    } catch (e) {
      debugPrint("💥 [FATAL ERROR] $e");
      state = const AuthState.error("Bağlantı hatası: İnternetinizi kontrol edin.");
    }
  }


  // ---------------------------------------------------------------------------
  // REGISTER/OTP DOĞRULAMA
  // ---------------------------------------------------------------------------
  Future<UserModel?> verifyOtpModel(String phone, String code, {bool isLogin = true}) async {
    debugPrint("🚀 [AUTH-FLOW] İşlem başladı. Tel: $phone | Mod: ${isLogin ? 'LOGIN' : 'REGISTER'}");
    state = const AuthState.loading();

    try {
      UserModel? user;

      // 1. ADIM: Backend İsteği
      if (isLogin) {
        // Kullanıcı mevcutsa giriş yap
        user = await repo.login(phone, code);
      } else {
        // Yeni kullanıcıysa OTP doğrula
        user = await repo.verifyOtp(phone, code);
      }

      // 2. ADIM: Başarılı Giriş Kontrolü
      if (user != null) {
        debugPrint("✅ [AUTH-SUCCESS] İşlem Başarılı. User: ${user.firstName ?? 'Yeni Kullanıcı'}");

        // Global kullanıcı bilgisini kaydet
        await ref.read(userNotifierProvider.notifier).saveUser(user);

        // Profil eksik mi kontrolü (İsim yoksa kullanıcı yeni kayıt aşamasındadır)
        final bool isProfileMissing = user.firstName == null ||
            user.firstName!.trim().isEmpty ||
            user.firstName == "null";

        // Uygulama durumlarını güncelle
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setIsNewUser(isProfileMissing);

        debugPrint("📢 [STATE] LoggedIn: true, NewUser: $isProfileMissing");

        state = const AuthState.authenticated();
        return user;
      }

      // 3. ADIM: Beklenmedik Boş Yanıt Durumu
      debugPrint("⚠️ [AUTH] İşlem başarısız: Repo null döndü.");
      state = const AuthState.error("Sunucudan geçerli bir yanıt alınamadı.");
      return null;

    } on DioException catch (e) {
      // 🎯 4. ADIM: Backend Hata Mesajını Yakalama
      // Loglarında gördüğümüz o meşhur "message" alanını buradan çekiyoruz
      final String serverMessage = e.response?.data?['message'] ?? "Kod doğrulanamadı, lütfen tekrar deneyin.";

      debugPrint("❌ [OTP-ERROR-BACKEND]: $serverMessage");

      // State'e "Geçersiz OTP" yerine backend'den gelen gerçek mesajı basıyoruz
      state = AuthState.error(serverMessage);
      return null;

    } catch (e) {
      // 5. ADIM: Yazılımsal veya Bağlantı Hataları
      debugPrint("❌ [AUTH-FATAL-ERROR] Hata: $e");
      state = AuthState.error("Beklenmedik bir hata oluştu: Lütfen internetinizi kontrol edin.");
      return null;
    }
  }


// ---------------------------------------------------------------------------
  // LOGIN (Eksiksiz & Akıllı Hata Yönetimi)
  // ---------------------------------------------------------------------------
  Future<UserModel?> login(String phone, String code) async {
    state = const AuthState.loading();
    try {
      final user = await repo.login(phone, code);

      if (user != null) {
        // Giriş başarılı
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        state = AuthState.authenticated(user);
        return user;
      }

      // User null geldiyse
      state = const AuthState.error("Kullanıcı bilgileri alınamadı.");
      return null;

    } on DioException catch (e) {
      // 🎯 Backend'den gelen mesajı yakalıyoruz: "Hatalı kod", "Hesap donduruldu" vb.
      final String serverMessage = e.response?.data?['message'] ?? "Giriş yapılamadı.";
      debugPrint("❌ [AUTH-LOGIN-ERROR]: $serverMessage");

      state = AuthState.error(serverMessage);
      return null;
    } catch (e) {
      debugPrint("💥 [AUTH-LOGIN-FATAL]: $e");
      state = const AuthState.error("Bağlantı hatası: Lütfen internetinizi kontrol edin.");
      return null;
    }
  }


  // ---------------------------------------------------------------------------
// /ME (Refactored: Uygulama Açılışında NewUser Temizliği)
// ---------------------------------------------------------------------------
  Future<bool> loadUserFromToken() async {
    debugPrint("📡 [AUTH] loadUserFromToken başlatıldı...");
    try {
      final user = await repo.me();

      if (user == null) {
        state = const AuthState.unauthenticated();
        return false;
      }

      // 1. Kullanıcıyı kaydet
      ref.read(userNotifierProvider.notifier).saveUser(user);

      // 🔥 2. DİNAMİK KONTROL: Uygulama her açıldığında profil durumunu kontrol et
      // Bu sayede başka cihazdaki profil tamamlama bilgisi buraya da yansır.
      final bool isReallyNew = user.firstName == null || user.firstName!.trim().isEmpty;
      await ref.read(appStateProvider.notifier).setIsNewUser(isReallyNew);

      debugPrint("📢 [AUTH LOAD] Profil Dolu mu?: ${!isReallyNew}");

      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      debugPrint("❌ [AUTH LOAD] Hata: $e");
      state = const AuthState.unauthenticated();
      return false;
    }
  }


  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    // API logout
    await repo.logout();

    // Token temizle
    await PrefsService.clearToken();

    // AppState reset
    ref.read(appStateProvider.notifier).resetAfterLogout();

    // UserState reset
    ref.read(userNotifierProvider.notifier).clearUser();

    // Auth state reset
    state = const AuthState.unauthenticated();

    debugPrint("🚀 LOGOUT COMPLETED");
  }

}
