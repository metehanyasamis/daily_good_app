import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../account/domain/providers/user_notifier.dart';
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

  AuthNotifier({required this.ref, required this.repo})
      : super(const AuthState.initial());

  // OTP gönder
  Future<void> sendOtp(String phone) async {
    state = const AuthState.loading();
    try {
      await repo.sendOtp(phone);
      state = const AuthState.otpSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

// OTP doğrulama + detaylı debug
  Future<bool> verifyOtp(String phone, String code) async {
    debugPrint("📨 [OTP] VerifyOtp() çağrıldı");
    debugPrint("➡️ phone: $phone");
    debugPrint("➡️ code: $code");

    try {
      state = const AuthState.loading();

      // Backend cevabını aldık (bool veya response olabilir)
      final ok = await repo.verifyOtp(phone, code);

      debugPrint("📥 [OTP] Backend verifyOtp RESULT → $ok");

      // Hatalı ise:
      if (!ok) {
        debugPrint("❌ [OTP] Doğrulama başarısız → state.invalidOtp()");
        state = const AuthState.invalidOtp();
        return false;
      }

      // Başarılı ise:
      debugPrint("✅ [OTP] Kod doğru → login'e devam edilebilir");
      return true;

    } catch (e, s) {
      debugPrint("🔥 [OTP] verifyOtp HATA → $e");
      debugPrint("🔥 Stacktrace → $s");

      state = AuthState.error(e.toString());
      return false;
    }
  }

  // Login
// Login
  Future<String> login(String phone, String code) async {
    debugPrint("🌐 [API] /login çağrılıyor...");

    try {
      final user = await repo.login(phone, code);

      // YENİ KULLANICI
      if (user == null) {
        debugPrint("🟡 Login → kullanıcı bulunamadı (NEW USER)");

        // ✔ GİRİŞİ BAŞARILI SAY – MUTLAKA!
        await ref.read(appStateProvider.notifier).setLoggedIn(true);

        // ✔ User temizle
        ref.read(userNotifierProvider.notifier).clearUser();

        // ✔ Onboarding flag'i
        await ref.read(appStateProvider.notifier).setOnboardingSeen(false);

        return "NEW";
      }

      // MEVCUT KULLANICI
      await ref.read(userNotifierProvider.notifier).saveUser(user);
      await ref.read(appStateProvider.notifier).setLoggedIn(true);

      state = AuthState.authenticated(user);

      debugPrint("🟢 Login → eski kullanıcı");
      return "EXISTING";

    } catch (e) {
      debugPrint("🔴 Login ERROR: $e");
      state = AuthState.error(e.toString());
      return "ERROR";
    }
  }




  // Token ile login (/me)
  Future<bool> loadUserFromToken() async {
    debugPrint("🔐 [Auth] loadUserFromToken() çağrıldı");

    try {
      final user = await repo.me();

      if (user == null) {
        debugPrint("❌ [Auth] /me başarısız → user null döndü");
        state = const AuthState.unauthenticated();
        return false;
      }

      debugPrint("✅ [Auth] /me başarılı → User ID: ${user.id}");

      await ref.read(userNotifierProvider.notifier).saveUser(user);

      debugPrint("📦 [Auth] User global state içine kaydedildi");

      state = AuthState.authenticated(user);

      debugPrint("🎉 [Auth] Kullanıcı login kabul edildi");
      return true;

    } catch (e) {
      debugPrint("🔥 [Auth] loadUserFromToken ERROR: $e");
      state = const AuthState.unauthenticated();
      return false;
    }
  }


  // Logout
  Future<void> logout() async {
    await repo.logout();

    ref.read(appStateProvider.notifier).setLoggedIn(false);
    ref.read(userNotifierProvider.notifier).clearUser();

    state = const AuthState.unauthenticated();
  }
}
