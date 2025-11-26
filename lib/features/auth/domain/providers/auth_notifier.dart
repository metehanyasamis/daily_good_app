import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../states/auth_state.dart';
import '../../../account/domain/providers/user_notifier.dart';

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(ref.watch(mockUserRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository authRepository;

  AuthNotifier({
    required this.ref,
    required this.authRepository,
  }) : super(const AuthState.initial());

  /// 🔍 Telefon kayıtlı mı?
  Future<bool> checkPhoneExists(String phone) async {
    return await authRepository.checkPhoneExists(phone);
  }

  /// 📩 OTP gönder
  Future<void> sendOtp(String phone) async {
    state = const AuthState.loading();
    await authRepository.sendOtp(phone);
    state = const AuthState.otpSent();
  }

  Future<void> verifyOtp(String phone, String otp) async {
    try {
      print("📨 VERIFY OTP → phone=$phone otp=$otp");

      state = const AuthState.loading();

      // OTP backend doğrula → user döner
      final user = await authRepository.verifyOtp(phone, otp);
      print("📦 BACKEND USER → id=${user.id}, phone=${user.phoneNumber}");

      // Kullanıcı bilgisini güncelle
      await ref.read(userNotifierProvider.notifier).updateUser(user);
      print("👤 USER STATE UPDATED");

      // Login flag
      final app = ref.read(appStateProvider.notifier);
      app.setLoggedIn(true);
      print("🔓 LOGGED IN SET → true");

      // ---- ÖNEMLİ: onboarding/location hiçbir şekilde elleme ----
      final appState = ref.read(appStateProvider);
      print("🔎 APP STATE BEFORE AUTH");
      print("   onboardingSeen=${appState.hasSeenOnboarding}");
      print("   locationSelected=${appState.hasSelectedLocation}");

      // Başarılı → UI dinleyip yönlendirecek
      print("➡️ EMIT authenticated state");
      state = AuthState.authenticated(user);

      print("✅ OTP DOĞRULANDI → USER=${user.id}");
      print("   onboardingSeen=${appState.hasSeenOnboarding}");
      print("   locationSelected=${appState.hasSelectedLocation}");

    } catch (e) {
      print("❌ OTP HATALI: $e");
      state = const AuthState.invalidOtp();
    }
  }



  /// 🚪 Logout → tüm appState temizlenmeli
  Future<void> logout() async {
    await authRepository.logout();

    final app = ref.read(appStateProvider.notifier);

    app.setLoggedIn(false);
    app.setOnboardingSeen(false);
    app.setLocationSelected(false);

    state = const AuthState.unauthenticated();
  }
}
