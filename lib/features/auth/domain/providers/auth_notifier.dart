import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../account/domain/providers/user_notifier.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../states/auth_state.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    repo: ref.read(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository repo;

  AuthNotifier({required this.ref, required this.repo}) : super(const AuthState.initial());

  /// OTP Gönder
  Future<void> sendOtp(String phone) async {
    state = const AuthState.loading();
    try {
      await repo.sendOtp(phone);
      state = const AuthState.otpSent();
    } catch (e) {
      debugPrint("❌ OTP Gönderme hatası: $e");
      state = AuthState.error(e.toString());
    }
  }

  /// OTP Doğrula (Sadece kontrol – login yapmaz)
  Future<bool> verifyOtp(String phone, String code) async {
    debugPrint("🔑 OTP doğrulama başlıyor → $phone, $code");
    try {
      state = const AuthState.loading();
      final success = await repo.verifyOtp(phone, code);
      if (!success) {
        debugPrint("❌ OTP hatalı");
        state = const AuthState.invalidOtp();
        return false;
      }
      debugPrint("✅ OTP doğru");
      return true;
    } catch (e, s) {
      debugPrint("🔥 OTP Doğrulama HATA: $e");
      debugPrint("🔥 Stack: $s");
      state = AuthState.error(e.toString());
      return false;
    }
  }

  /// Giriş (Login) – Hem eski hem yeni kullanıcıyı kapsar
  Future<String> login(String phone, String code) async {
    debugPrint("🌍 Login başlıyor...");

    try {
      final loginResponse = await repo.login(phone, code);

      debugPrint("📦 Login Response: $loginResponse");
      debugPrint("📦 Token: ${loginResponse?.token}");

      if (loginResponse == null) {
        debugPrint("❌ loginResponse kendisi null → login başarısız");
        return "ERROR";
      }

      if (loginResponse.token == null || loginResponse.token!.isEmpty) {
        debugPrint("❌ Login başarısız → token null veya boş");
        return "ERROR";
      }

      // Giriş başarılıysa → Şimdi kullanıcı bilgisini alalım
      final user = await repo.me();

      if (user == null) {
        debugPrint("🟡 /me null → yeni kullanıcı olabilir");
        ref.read(userNotifierProvider.notifier).clearUser();

        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setOnboardingSeen(false);

        return "NEW";
      }

      // Kullanıcı bulundu → kaydet
      await ref.read(userNotifierProvider.notifier).saveUser(user);
      await ref.read(appStateProvider.notifier).setLoggedIn(true);

      state = AuthState.authenticated(user);
      debugPrint("🟢 Giriş başarılı, mevcut kullanıcı.");
      return "EXISTING";

    } catch (e, s) {
      debugPrint("🔥 Login HATA: $e");
      debugPrint("🔥 Stacktrace: $s");
      state = AuthState.error(e.toString());
      return "ERROR";
    }
  }

  /// Token ile kullanıcıyı yeniden yükle (/me)
  Future<bool> loadUserFromToken() async {
    debugPrint("🔐 Token ile kullanıcı yükleniyor...");
    try {
      final user = await repo.me();
      if (user == null) {
        debugPrint("🚫 /me null → kullanıcı yok");
        state = const AuthState.unauthenticated();
        return false;
      }

      await ref.read(userNotifierProvider.notifier).saveUser(user);
      state = AuthState.authenticated(user);
      debugPrint("✅ Token ile giriş başarılı.");
      return true;

    } catch (e) {
      debugPrint("❌ Token ile yükleme hatası: $e");
      state = const AuthState.unauthenticated();
      return false;
    }
  }

  /// Çıkış
  Future<void> logout() async {
    debugPrint("👋 Logout işlemi başladı");
    await repo.logout();

    await ref.read(appStateProvider.notifier).setLoggedIn(false);
    ref.read(userNotifierProvider.notifier).clearUser();
    state = const AuthState.unauthenticated();
    debugPrint("👋 Logout tamamlandı");
  }
}
