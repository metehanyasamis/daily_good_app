import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return true;
  }

  // ---------------------------------------------------------------------------
// TELEFON KAYITLI MI?
// ---------------------------------------------------------------------------
  Future<bool> isPhoneRegistered(String phone) async {
    try {
      final exists = await repo.checkPhone(phone);
      debugPrint("📞 [AUTH] isPhoneRegistered = $exists");
      return exists;
    } catch (e) {
      debugPrint("🔥 [AUTH] isPhoneRegistered ERROR: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------------------------
  Future<String> login(String phone, String code) async {
    debugPrint("🌍 Login → $phone");

    try {
      final user = await repo.login(phone, code);

      // Yeni kullanıcı
      if (user == null) {
        ref.read(appStateProvider.notifier).setLoggedIn(true);
        ref.read(appStateProvider.notifier).setIsNewUser(true);

        final newUser = UserModel(
          id: "",
          phone: phone,
        );

        ref.read(userNotifierProvider.notifier).saveUserLocally(newUser);
        state = const AuthState.authenticated();

        return "NEW";
      }

      // Mevcut kullanıcı
      ref.read(userNotifierProvider.notifier).saveUser(user);
      ref.read(appStateProvider.notifier).setLoggedIn(true);

      state = AuthState.authenticated(user);
      return "EXISTING";
    } catch (e) {
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
    await repo.logout();
    ref.read(appStateProvider.notifier).setLoggedIn(false);
    ref.read(userNotifierProvider.notifier).clearUser();
    state = const AuthState.unauthenticated();
  }
}
