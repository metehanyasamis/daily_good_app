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

// auth_notifier.dart içindeki metod
  Future<void> sendOtp({required String phone, required String purpose}) async {
    state = const AuthState.loading();
    debugPrint("📡 [OTP REQUEST] $phone ($purpose)");

    try {
      final bool ok = await repo.sendOtp(phone, purpose: purpose);

      if (ok) {
        debugPrint("✅ [OTP RESPONSE] Başarılı");
        state = const AuthState.otpSent();
      } else {
        state = const AuthState.error("Beklenmedik bir sorun oluştu.");
      }
    } on DioException catch (e) {
      // 🔥 Backend'den gelen o meşhur mesajları burada yakalıyoruz:
      final String serverMessage = e.response?.data?['message'] ?? "İşlem başarısız oldu.";
      final String? errorCode = e.response?.data?['error_code'];

      debugPrint("❌ [BACKEND ERROR] Message: $serverMessage, Code: $errorCode");

      // State'e gerçek mesajı basıyoruz
      state = AuthState.error(serverMessage);
    } catch (e) {
      debugPrint("💥 [FATAL ERROR] $e");
      state = const AuthState.error("Bağlantı hatası: Lütfen internetinizi kontrol edin.");
    }
  }


// ---------------------------------------------------------------------------
// REGISTER/OTP DOĞRULAMA (YENİ KULLANICI İÇİN)
// ---------------------------------------------------------------------------
  Future<UserModel?> verifyOtpModel(String phone, String code) async {
    debugPrint("🚀 [VERIFY-OTP] İşlem başladı. Tel: $phone");
    state = const AuthState.loading();
    try {
      final user = await repo.verifyOtp(phone, code);

      if (user != null) {
        debugPrint("✅ [VERIFY-OTP] Başarılı! UserID: ${user.id}, Token: ${user.token != null ? 'VAR' : 'YOK'}");

        // 1. Önce global kullanıcı bilgisini dolduruyoruz (Router buraya bakıyor!)
        ref.read(userNotifierProvider.notifier).saveUser(user);
        debugPrint("📢 [USER DATA] UserNotifier güncellendi.");

        // 2. Sisteme giriş durumlarını set ediyoruz
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setIsNewUser(true);
        debugPrint("📢 [STATE UPDATE] LoggedIn ve NewUser set edildi.");

        // 3. State'i güncelleyip kullanıcıyı döndürüyoruz
        state = const AuthState.authenticated();
        return user;
      }

      debugPrint("⚠️ [VERIFY-OTP] User null döndü!");
      state = const AuthState.invalidOtp();
      return null;
    } catch (e) {
      debugPrint("❌ [VERIFY-OTP] Hata: $e");
      state = AuthState.error(e.toString());
      return null;
    }
  }

  // ---------------------------------------------------------------------------
// LOGIN (SADE VE MODEL DÖNEN)
// ---------------------------------------------------------------------------
  Future<UserModel?> login(String phone, String code) async {
    state = const AuthState.loading();
    try {
      final user = await repo.login(phone, code);

      if (user != null) {
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        state = AuthState.authenticated(user);
        return user; // ✨ ARTIK DOĞRU TİP DÖNÜYOR (UserModel)
      }

      return null;
    } catch (e) {
      state = AuthState.error(e.toString());
      return null;
    }
  }
  // ---------------------------------------------------------------------------
  // /me
  // ---------------------------------------------------------------------------

  Future<bool> loadUserFromToken() async {
    debugPrint("📡 [AUTH] loadUserFromToken başlatıldı...");
    try {
      final user = await repo.me();

      if (user == null) {
        state = const AuthState.unauthenticated();
        return false;
      }

      ref.read(userNotifierProvider.notifier).saveUser(user);
      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      // Hata olsa bile Splash'ten çıkmak için false dön
      state = const AuthState.unauthenticated();
      return false;
    }
  }

  /*
  Future<bool> loadUserFromToken() async {
    final user = await repo.me();

    if (user == null) {
      state = const AuthState.unauthenticated();
      return false;
    }

    ref.read(userNotifierProvider.notifier).saveUser(user);
    state = AuthState.authenticated(user);
    return true;
  }

   */

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
