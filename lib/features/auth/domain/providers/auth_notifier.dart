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
// REGISTER/OTP DOĞRULAMA (Refactored: Dinamik NewUser Kontrolü)
// ---------------------------------------------------------------------------

  Future<UserModel?> verifyOtpModel(String phone, String code, {bool isLogin = true}) async {
    debugPrint("🚀 [AUTH-FLOW] İşlem başladı. Tel: $phone | Mod: ${isLogin ? 'LOGIN' : 'REGISTER'}");
    state = const AuthState.loading();

    try {
      UserModel? user;

      if (isLogin) {
        // 1. DURUM: Kullanıcı zaten var, sadece giriş yapıyor
        user = await repo.login(phone, code);
      } else {
        // 2. DURUM: Kullanıcı yeni kayıt oluyor, önce OTP doğrulanmalı
        // Repository'deki verifyOtp metodunu çağırıyoruz
        user = await repo.verifyOtp(phone, code);
      }

      if (user != null) {
        debugPrint("✅ [AUTH-SUCCESS] İşlem Başarılı. User: ${user.firstName ?? 'Yeni Kullanıcı'}");

        // Global kullanıcı bilgisini kaydet
        await ref.read(userNotifierProvider.notifier).saveUser(user);

        // Profil eksik mi kontrolü (Eğer isim yoksa bu kullanıcı yenidir)
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

      // Eğer repo null döndüyse (Hatalı kod veya 404 durumu)
      debugPrint("⚠️ [AUTH] İşlem başarısız. Repo null döndü.");
      state = const AuthState.invalidOtp();
      return null;

    } catch (e) {
      debugPrint("❌ [AUTH-ERROR] Hata: $e");
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
