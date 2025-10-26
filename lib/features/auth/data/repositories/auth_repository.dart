import '../../../account/data/models/user_model.dart';
import '../../../account/data/repositories/user_repository.dart';

/// Kullanıcı kimlik doğrulama işlemleri için temel arayüz
abstract class AuthRepository {
  Future<UserModel> loginWithPhone(String phoneNumber);
  Future<UserModel> verifyOtp(String phoneNumber, String otp);
  Future<void> logout();
}

/// MockAuthRepository — yalnızca test / local geliştirme ortamı için
class MockAuthRepository implements AuthRepository {
  final MockUserRepository _userRepository;

  MockAuthRepository(this._userRepository);

  @override
  Future<UserModel> loginWithPhone(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = UserModel(
      id: '1',
      phoneNumber: phoneNumber,
      token: 'mock_token',
      isPhoneVerified: true,
      isEmailVerified: false,
    );

    // Kullanıcıyı kaydet
    _userRepository.setMockUser(user);
    return user;
  }

  @override
  Future<UserModel> verifyOtp(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (otp == '12345') {
      final verifiedUser = _userRepository.getMockUser().copyWith(
        phoneNumber: phoneNumber,
        isPhoneVerified: true,
        token: 'mock_token_verified',
      );

      // ✅ Telefon doğrulandıktan sonra repository'yi güncelle
      _userRepository.setMockUser(verifiedUser);

      // ✅ loadUser() çağrılarında güncel user dönecek
      return _userRepository.getMockUser();
    } else {
      throw Exception('Geçersiz doğrulama kodu');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock ortamında logout yalnızca gecikme simülasyonu yapar
  }
}
