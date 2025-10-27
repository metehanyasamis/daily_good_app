import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/prefs_service.dart';
import '../states/user_state.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

/// Tek bir MockUserRepository paylaşımı
final mockUserRepositoryProvider = Provider<MockUserRepository>((ref) {
  return MockUserRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return ref.watch(mockUserRepositoryProvider);
});

final userNotifierProvider =
StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(userRepository: ref.watch(userRepositoryProvider));
});

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _userRepository;

  UserNotifier({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserState.initial()) {
    // 🔹 Future.microtask ile async çalışmayı build sonrası başlat
    Future.microtask(() => _restoreUserFromPrefs());
  }


  Future<void> init() async {
    await _restoreUserFromPrefs();
  }

  /// 🔹 SharedPreferences içindeki kullanıcıyı geri yükle
  Future<void> _restoreUserFromPrefs() async {
    try {
      final userMap = await PrefsService.readUserData();
      if (userMap != null) {
        final restoredUser = UserModel.fromJson(userMap);
        // ✅ state değişikliği burada rebuild tetikler
        state = UserState.ready(restoredUser);
      } else {
        state = const UserState.initial();
      }
    } catch (e) {
      state = const UserState.initial();
    }
  }

  /// 🔹 API’den veya mock’tan user yükle
  Future<void> loadUser({bool forceRefresh = false}) async {
    // ⚠️ eğer kullanıcı zaten yüklüyse ve zorunlu yenileme istenmiyorsa, hiçbir şey yapma
    if (!forceRefresh && state.user != null) return;

    try {
      state = const UserState.loading();
      final user = await _userRepository.fetchUser();
      state = UserState.ready(user);

      await PrefsService.saveUserData(user.toJson());
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 🔹 Kullanıcıyı güncelle (UI + local cache)
  Future<void> updateUser(UserModel updatedUser) async {
    state = state.copyWith(user: updatedUser, status: UserStatus.ready);
    try {
      final user = await _userRepository.updateUser(updatedUser);
      state = UserState.ready(user);

      // ✅ Kalıcı kaydet
      await PrefsService.saveUserData(user.toJson());
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 🔹 E-posta gönderimi
  Future<void> sendEmailVerification(String email) async {
    try {
      final updated = await _userRepository.updateEmail(email);
      final current = state.user;
      state = state.copyWith(
        user: current?.copyWith(
          email: updated.email,
          isEmailVerified: false,
        ) ??
            updated,
      );

      // ✅ local cache güncelle
      await PrefsService.saveUserData(state.user!.toJson());
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 🔹 OTP doğrulama (yalnızca flag değiştirir)
  Future<void> verifyEmailOtp(String otp) async {
    try {
      final currentUser = state.user;
      if (currentUser == null) return;

      await _userRepository.verifyEmailOtpCode(otp);

      state = state.copyWith(
        user: currentUser.copyWith(isEmailVerified: true),
      );

      // ✅ local cache’e kaydet
      await PrefsService.saveUserData(state.user!.toJson());
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 🔹 Hesap silme
  Future<void> deleteUserAccount() async {
    try {
      await _userRepository.deleteAccount();
      state = const UserState.initial();
      await PrefsService.clearUserData(); // ✅ localden de sil
    } catch (e) {
      state = state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// 🔹 Logout (state + local temizle)
  void logout() async {
    state = const UserState.initial();
    await PrefsService.clearUserData();
  }
}
