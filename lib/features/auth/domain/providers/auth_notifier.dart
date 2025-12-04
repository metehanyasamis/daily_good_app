import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../../account/data/models/user_model.dart';
import '../../../account/domain/providers/user_notifier.dart';
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
  // OTP GÖNDER
  // ---------------------------------------------------------------------------
  Future<void> sendOtp(String phone) async {
    debugPrint("📲 [AUTH] sendOtp → $phone");
    state = const AuthState.loading();

    try {
      await repo.sendOtp(phone);
      debugPrint("✅ [AUTH] OTP gönderildi");
      state = const AuthState.otpSent();
    } catch (e) {
      debugPrint("🔥 [AUTH] sendOtp HATA: $e");
      state = AuthState.error(e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // OTP DOĞRULAMA (Sadece kontrol)
  // ---------------------------------------------------------------------------
  Future<bool> verifyOtp(String phone, String code) async {
    debugPrint("🔑 [AUTH] OTP doğrulanıyor → phone=$phone code=$code");

    try {
      state = const AuthState.loading();

      final ok = await repo.verifyOtp(phone, code);

      if (!ok) {
        debugPrint("❌ [AUTH] OTP hatalı");
        state = const AuthState.invalidOtp();
        return false;
      }

      debugPrint("✅ [AUTH] OTP doğru");
      return true;
    } catch (e) {
      debugPrint("🔥 [AUTH] verifyOtp HATA: $e");
      state = AuthState.error(e.toString());
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN (Yeni + Mevcut)
  // ---------------------------------------------------------------------------
  Future<String> login(String phone, String code) async {
    debugPrint("🌍 [AUTH] Login başlıyor... phone=$phone");

    try {
      final user = await repo.login(phone, code); // repo.login içinde token kaydediliyor.

      // ---------------------- YENİ KULLANICI ----------------------
      if (user == null) {
        debugPrint("🟡 [AUTH] Yeni kullanıcı oluşturuluyor (backend null döndü)");

        final newUser = UserModel(
          id: "",
          phone: phone,
          token: null,
          firstName: null,
          lastName: null,
          email: null,
          birthDate: null,
          isEmailVerified: false,
        );

        // Sadece local hafızaya alıyoruz
        ref.read(userNotifierProvider.notifier).saveUserLocally(newUser);

        // App state
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setNewUser(true);

        debugPrint("🟡 [AUTH] Yeni kullanıcı kaydedildi → ProfileDetails açılacak");

        return "NEW";
      }

      // --------------------- MEVCUT KULLANICI ---------------------
      debugPrint("📦 [AUTH] Login → $user");

      final fixedUser = user.copyWith(phone: phone);

      // Token kontrolünü (geçici olarak kaldırdığımızı varsayarak) yaptık/atladık.

      // 💡 YENİ KONTROL: Kullanıcının zorunlu alanları (örn: isim) eksik mi?
      final isNewUser = fixedUser.firstName == null || fixedUser.firstName!.isEmpty;

      if (isNewUser) {
        debugPrint("🟡 [AUTH] Mevcut kullanıcı, fakat zorunlu alanları eksik. Profil detayına yönlendiriliyor.");

        // 1. Yeni kullanıcı state'ini ayarlıyoruz
        ref.read(userNotifierProvider.notifier).saveUserLocally(fixedUser);
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setNewUser(true); // 👈 BURASI KRİTİK!

        state = AuthState.authenticated(fixedUser);
        return "NEW_BUT_EXISTING_DB"; // Yeni bir dönüş tipi tanımlayabilirsiniz.
      }


      // ---- HER ŞEY TAMAM LAN KULLANICI İÇİN AKIŞ ----

      ref.read(userNotifierProvider.notifier).saveUser(fixedUser);
      await ref.read(appStateProvider.notifier).setLoggedIn(true);

      state = AuthState.authenticated(fixedUser);

      return "EXISTING"; // Gerçekten tamamlanmış kullanıcı.
    } catch (e) {
      debugPrint("🔥 [AUTH] Login HATA: $e");
      state = AuthState.error(e.toString());
      return "ERROR";
    }
  }

  // ---------------------------------------------------------------------------
  // TELEFON KAYITLI MI?
  // ---------------------------------------------------------------------------
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final exists = await repo.checkPhone(phone);
      debugPrint("📞 [AUTH] isPhoneRegistered=$exists");
      return exists;
    } catch (e) {
      debugPrint("🔥 [AUTH] isPhoneRegistered HATA: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // /me → Splash için gerekli
  // ---------------------------------------------------------------------------
  Future<bool> loadUserFromToken() async {
    debugPrint("🔐 [AUTH] /me yükleniyor...");

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
      state = const AuthState.unauthenticated();
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    debugPrint("👋 [AUTH] Logout");

    try {
      await repo.logout();
    } catch (_) {}

    await ref.read(appStateProvider.notifier).setLoggedIn(false);
    ref.read(userNotifierProvider.notifier).clearUser();

    state = const AuthState.unauthenticated();
  }
}
