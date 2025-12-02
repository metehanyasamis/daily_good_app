import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/data/prefs_service.dart';
import '../../../account/data/models/user_model.dart';
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
      final user = await repo.login(phone, code);

      if (user == null) {
        debugPrint("❌ loginResponse null → kullanıcı kayıtlı değil (YENİ KULLANICI)");

        // YENİ KULLANICI MODELİ OLUŞTURMA:
        // Yeni kullanıcı için token almadığımızı varsayarsak,
        // sadece zorunlu alan olan 'phone' ile bir UserModel oluşturmalıyız.
        // ID alanı backend tarafından atanacağı için, ID'yi geçici olarak boş bırakıyoruz.
        final newUserModel = UserModel(
          id: '', // Geçici ID
          phone: phone,
          token: null, // Token yok
        );

        // Sadece telefon bilgisi olan modeli UserNotifier'a kaydedelim
        // Ancak bu, appStateProvider'ı isLoggedIn=true yapmayabilir.
        // Bu yüzden, ProfileDetailsScreen'da kullanabilmek için manuel olarak kaydedelim.
        ref.read(userNotifierProvider.notifier).saveUserLocally(newUserModel); // Yeni metot
        await ref.read(appStateProvider.notifier).setLoggedIn(true); // Token olmasa da giriş yaptı sayıyoruz.

        return "NEW";
      }

      debugPrint("📦 Login UserModel: $user");
      debugPrint("📦 Token: ${user.token}");

      if (user.token == null || user.token!.isEmpty) {
        debugPrint("❌ Token null veya boş → login başarısız");
        return "ERROR";
      }

      await PrefsService.saveToken(user.token!);
      ref.read(userNotifierProvider.notifier).saveUser(user);
      await ref.read(appStateProvider.notifier).setLoggedIn(true);
      state = AuthState.authenticated(user);

      debugPrint("🟢 Giriş başarılı → mevcut kullanıcı");
      return "EXISTING";

    } catch (e, s) {
      debugPrint("🔥 Login HATA: $e");
      debugPrint("🔥 Stacktrace: $s");
      state = AuthState.error(e.toString());
      return "ERROR";
    }
  }


  /// Telefon kontrolü (Yeni kullanıcı olup olmadığını kontrol eder)
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      return await repo.checkPhone(phone);
    } catch (e) {
      debugPrint("❌ Telefon kontrol hatası: $e");
      return false; // hata varsa kayıtlı değilmiş gibi davran
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

  final secureStorage = FlutterSecureStorage();

  Future<String> verifyOtpAndLogin(String phone, String code, WidgetRef ref) async {
    try {
      debugPrint("🔑 OTP doğrulama başlıyor → $phone, $code");

      final otpResponse = await repo.verifyOtp(phone, code);
      if (!otpResponse) {
        state = const AuthState.invalidOtp();
        return "INVALID_OTP"; // OTP başarısız olursa
      }

      debugPrint("✅ OTP doğru");
      debugPrint("🟢 [OTP] Kod doğru → login çağrılıyor...");

      // Login ile devam et
      final result = await login(phone, code);

      debugPrint("✨ [OTP] Login Sonucu → $result");
      return result; // "EXISTING" veya "NEW_USER" veya "ERROR" dönecek

    } on DioException catch (e) {
      debugPrint("🔥 DioException (verifyOtpAndLogin): ${e.message}");
      return "ERROR";
    } catch (e, s) {
      debugPrint("🔥 verifyOtpAndLogin() genel hata: $e");
      debugPrint("🔥 Stacktrace: $s");
      return "ERROR";
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
