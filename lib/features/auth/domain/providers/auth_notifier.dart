import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../states/auth_state.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../account/domain/providers/user_notifier.dart'; // <-- Bunu ekle

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // ✅ UserNotifier ile aynı MockUserRepository'yi kullanıyoruz
  return MockAuthRepository(ref.watch(mockUserRepositoryProvider));
});

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref, // ✅ burası önemli
    authRepository: ref.watch(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository authRepository;

  AuthNotifier({required this.ref,required this.authRepository}) : super(const AuthState.initial());

  Future<void> login(String phoneNumber) async {
    try {
      state = const AuthState.loading();
      await authRepository.loginWithPhone(phoneNumber);
      state = const AuthState.otpSent();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> verifyOtp(BuildContext context, String phoneNumber, String otp) async {
    try {
      state = const AuthState.loading();

      // 1️⃣ OTP doğrulaması
      final user = await authRepository.verifyOtp(phoneNumber, otp);

      // 2️⃣ Doğrulanan user'ı UserNotifier'a aktar
      ref.read(userNotifierProvider.notifier).updateUser(user);

      // 3️⃣ State'i güncelle
      state = AuthState.authenticated(user);

      // 4️⃣ Profil detay ekranına yönlendir
      if (context.mounted) {
        context.go('/profileDetail');
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }


  Future<void> logout() async {
    await authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}
