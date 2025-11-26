import '../../../account/data/models/user_model.dart';
import '../../../account/data/repositories/user_repository.dart';

/// Kullanıcı kimlik doğrulama işlemleri için temel arayüz
abstract class AuthRepository {
  Future<bool> checkPhoneExists(String phoneNumber);
  Future<void> sendOtp(String phoneNumber);
  Future<UserModel> verifyOtp(String phoneNumber, String otp);
  Future<void> logout();
}

/// MockAuthRepository — yalnızca test / local geliştirme ortamı için
class MockAuthRepository implements AuthRepository {
  final MockUserRepository _userRepository;

  MockAuthRepository(this._userRepository);

  @override
  Future<bool> checkPhoneExists(String phone) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final user = _userRepository.getMockUser();
    return user != null && user.phoneNumber == phone;
  }

  @override
  Future<void> sendOtp(String phone) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock'ta sadece bekliyoruz
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // ❗ OTP yanlış → direkt HATA
    if (otp != "12345") {
      throw Exception("Geçersiz doğrulama kodu");
    }

    // 📌 OTP doğruysa buradan sonrası çalışır
    final existing = _userRepository.getMockUser();

    // 🔥 1) Kullanıcı önceden varsa → LOGIN
    if (existing != null && existing.phoneNumber == phone) {
      final updated = existing.copyWith(
        token: "mock_token_verified",
        isPhoneVerified: true,
      );
      _userRepository.setMockUser(updated);
      return updated;
    }

    // 🔥 2) Kullanıcı yoksa → REGISTER
    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      phoneNumber: phone,
      isPhoneVerified: true,
      token: "mock_token_new_user",
      isEmailVerified: false,
    );

    _userRepository.setMockUser(newUser);
    return newUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
