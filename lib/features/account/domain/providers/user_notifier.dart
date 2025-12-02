import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../states/user_state.dart';
import '../../../../core/data/prefs_service.dart';

final userNotifierProvider =
StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref: ref,
    repository: ref.read(userRepositoryProvider),
  );
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final UserRepository repository;

  UserNotifier({
    required this.ref,
    required this.repository,
  }) : super(const UserState.initial());

  // ------------------------------------------------------------------
  // LOCAL USER SAVE (login veya /me sonrası)
  // ------------------------------------------------------------------
  Future<void> saveUser(UserModel user) async {
    // Sadece token varsa kaydediyoruz (Existing user)
    if (user.token != null && user.token!.isNotEmpty) {
      await PrefsService.saveToken(user.token!);
    }
    state = UserState.ready(user);
  }


// ------------------------------------------------------------------
// YENİ METOT: Sadece objeyi kaydet, token yoksa zorlama
// ------------------------------------------------------------------
  void saveUserLocally(UserModel user) {
    state = UserState.ready(user);
  }


  // ------------------------------------------------------------------
  // LOCAL CLEAR — logout
  // ------------------------------------------------------------------
  void clearUser() {
    PrefsService.clearAll();
    state = const UserState.initial();
  }

  // ------------------------------------------------------------------
  // /me çağır
  // ------------------------------------------------------------------
  Future<void> loadUser({bool forceRefresh = true}) async {
    try {
      state = const UserState.loading();

      final user = await repository.fetchUser();

      state = UserState.ready(user);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  // ------------------------------------------------------------------
  // Profil Güncelle
  // ------------------------------------------------------------------
  Future<void> updateUser(UserModel updated) async {
    try {
      state = const UserState.loading();

      final user = await repository.updateUser(updated);

      state = UserState.ready(user);
    } catch (e) {
      state = UserState.error(e.toString());
    }
  }

  // ------------------------------------------------------------------
  // E-Posta OTP Gönder
  // ------------------------------------------------------------------
  Future<void> sendEmailVerification(String email) async {
    await repository.sendEmailVerification(email);
  }

  // ------------------------------------------------------------------
  // E-Posta OTP Doğrula
  // ------------------------------------------------------------------
  Future<UserModel> verifyEmailOtp(String otp) async {
    final user = await repository.verifyEmailOtpCode(otp);
    state = UserState.ready(user);
    return user;
  }

  // ------------------------------------------------------------------
  // Telefon Güncelle
  // ------------------------------------------------------------------
  Future<void> updatePhone(String phone) async {
    final user = await repository.updatePhoneNumber(phone);
    state = UserState.ready(user);
  }

  // ------------------------------------------------------------------
  // Hesap Sil
  // ------------------------------------------------------------------
  Future<void> deleteUserAccount() async {
    await repository.deleteAccount();
    clearUser();
  }
}
