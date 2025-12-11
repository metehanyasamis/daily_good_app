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

  // ---------------------------------------------------------------------------
  // OTP GÖNDER (TEK DOĞRU YERİ)
  // ---------------------------------------------------------------------------
  Future<bool> sendOtp(String phone) async {
    debugPrint("📲 [AUTH] OTP gönderiliyor → $phone");
    state = const AuthState.loading();

    final ok = await repo.sendOtp(phone);

    if (ok) {
      state = const AuthState.otpSent();
      return true;
    } else {
      state = const AuthState.error("OTP gönderilemedi");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // OTP DOĞRULAMA
  // ---------------------------------------------------------------------------
  Future<bool> verifyOtp(String phone, String code) async {
    debugPrint("🔑 OTP doğrulanıyor...");

    state = const AuthState.loading();

    final ok = await repo.verifyOtp(phone, code);

    if (!ok) {
      state = const AuthState.invalidOtp();
      return false;
    }

    debugPrint("🔵 [OTP] Yeni kullanıcı OTP doğrulandı!");

    // ----------------------------------------------------------
    // 1) Kullanıcı "geçici olarak login" kabul edilmeli
    // ----------------------------------------------------------
    await ref.read(appStateProvider.notifier).setLoggedIn(true);

    // ----------------------------------------------------------
    // 2) Yeni kullanıcı akışını başlat
    // ----------------------------------------------------------
    await ref.read(appStateProvider.notifier).setIsNewUser(true);

    // profil doldurmadığı için zorunlu
    await ref.read(appStateProvider.notifier).setHasSeenProfileDetails(false);

    // onboarding daha yapılmadı
    await ref.read(appStateProvider.notifier).setHasSeenOnboarding(false);

    // ----------------------------------------------------------
    // 3) UserModel'i geçici olarak oluştur
    // ----------------------------------------------------------
    final tempUser = UserModel(
      id: "",
      phone: phone,
    );

    ref.read(userNotifierProvider.notifier).saveUserLocally(tempUser);

    // ----------------------------------------------------------
    // 4) Auth state başarıya döner
    // ----------------------------------------------------------
    state = const AuthState.authenticated();

    return true;
  }



  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------
  Future<String> login(String phone, String code) async {
    debugPrint("🌍 Login → $phone");

    try {
      final user = await repo.login(phone, code);

      // -------------------------
      // 1) Yeni kullanıcı
      // -------------------------
      if (user == null) {
        debugPrint("🆕 [AUTH] Yeni kullanıcı algılandı");

        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setIsNewUser(true);

        final newUser = UserModel(
          id: "",
          phone: phone,
        );

        ref.read(userNotifierProvider.notifier).saveUserLocally(newUser);

        state = const AuthState.authenticated();
        return "NEW";
      }

      // -------------------------
      // 2) Mevcut kullanıcı
      // -------------------------

      // 2A) Token kaydet
      if (user.token != null && user.token!.isNotEmpty) {
        await PrefsService.saveToken(user.token!);
        debugPrint("🔑 Token kaydedildi → ${user.token}");
      } else {
        debugPrint("⚠️ [AUTH] USER TOKEN GELMEDİ! API'yi kontrol edin.");
      }

      // 2B) AppState: logged in
      await ref.read(appStateProvider.notifier).setLoggedIn(true);

      // 2C) User geçici olarak kaydedilir
      ref.read(userNotifierProvider.notifier).saveUser(user);

      // 2D) 💥 /me çağrısı — temiz profil
      debugPrint("📡 /me çağrılıyor (login sonrası tam user için)");

      final fullUser = await repo.me();

      if (fullUser != null) {
        ref.read(userNotifierProvider.notifier).saveUser(fullUser);
        state = AuthState.authenticated(fullUser);
      } else {
        debugPrint("⚠️ [AUTH] /me NULL döndü — backend login/me tutarsız olabilir.");
        state = AuthState.authenticated(user);
      }

      return "EXISTING";
    } catch (e) {
      debugPrint("❌ LOGIN ERROR: $e");
      state = AuthState.error(e.toString());
      return "ERROR";
    }
  }

  // ---------------------------------------------------------------------------
  // /me
  // ---------------------------------------------------------------------------
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
