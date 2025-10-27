import '../models/user_model.dart';

/// Kullanıcı işlemleri için soyut repository arayüzü
abstract class UserRepository {
  Future<UserModel> fetchUser();
  Future<UserModel> updateUser(UserModel user);
  Future<void> deleteAccount();
  Future<UserModel> updatePhoneNumber(String phoneNumber);
  Future<UserModel> updateEmail(String email);
  Future<UserModel> verifyEmailOtpCode(String otp);
}

/// MockUserRepository — sadece test / local senaryolar için
class MockUserRepository implements UserRepository {
  UserModel _mockUser = UserModel(
    id: '1',
    phoneNumber: '',
    token: '',
    isPhoneVerified: false,
    isEmailVerified: false,
    name: null,
    surname: null,
    email: null,
    gender: null,
  );

  UserModel getMockUser() => _mockUser;
  void setMockUser(UserModel user) => _mockUser = user;

  @override
  Future<UserModel> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser;
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockUser = _mockUser.copyWith(
      id: user.id.isNotEmpty ? user.id : _mockUser.id,
      name: user.name ?? _mockUser.name,
      surname: user.surname ?? _mockUser.surname,
      email: user.email ?? _mockUser.email,
      gender: user.gender ?? _mockUser.gender,
      phoneNumber:
      user.phoneNumber.isNotEmpty ? user.phoneNumber : _mockUser.phoneNumber,
      isPhoneVerified: user.isPhoneVerified,
      isEmailVerified: user.isEmailVerified,
      token: user.token.isNotEmpty ? user.token : _mockUser.token,
    );
    return _mockUser;
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockUser = UserModel(
      id: '',
      phoneNumber: '',
      token: '',
      isPhoneVerified: false,
      isEmailVerified: false,
      name: null,
      surname: null,
      email: null,
      gender: null,
    );
  }

  @override
  Future<UserModel> updatePhoneNumber(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockUser = _mockUser.copyWith(
      phoneNumber: phoneNumber,
      isPhoneVerified: false,
    );
    return _mockUser;
  }

  /// ✅ Sadece e-posta alanını günceller, diğer tüm bilgiler korunur
  @override
  Future<UserModel> updateEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockUser = _mockUser.copyWith(
      email: email,
      isEmailVerified: false, // yeni e-posta doğrulanmamış olarak işaretlenir
    );
    return _mockUser;
  }

  /// ✅ E-posta doğrulama kodu — sadece isEmailVerified alanını değiştirir
  @override
  Future<UserModel> verifyEmailOtpCode(String otp) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (otp == '12345') {
      // ✅ var olan bilgileri koruyarak sadece doğrulama bilgisini güncelle
      _mockUser = _mockUser.copyWith(
        isEmailVerified: true,
        email: _mockUser.email,
        name: _mockUser.name,
        surname: _mockUser.surname,
        gender: _mockUser.gender,
        phoneNumber: _mockUser.phoneNumber,
        isPhoneVerified: _mockUser.isPhoneVerified,
        id: _mockUser.id,
        token: _mockUser.token,
      );
      return _mockUser;
    } else {
      throw Exception('Geçersiz e-posta doğrulama kodu');
    }
  }
}
