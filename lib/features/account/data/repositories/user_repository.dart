import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> fetchUser();
  Future<UserModel> updateUser(UserModel data);
  Future<void> sendEmailVerification(String email);
  Future<UserModel> verifyEmailOtpCode(String email, String code);
  Future<UserModel> updatePhoneNumber(String phone);
  Future<void> deleteAccount();
  Future<void> sendEmailChangeOtp(String newEmail);
  Future<UserModel> verifyEmailChangeOtp(String email, String code);
}

class UserRepositoryImpl implements UserRepository {
  final ApiClient api;

  UserRepositoryImpl(this.api);

// ----------------------------------------------------------------------
// GET /customer/auth/me
// ----------------------------------------------------------------------
  @override
  Future<UserModel> fetchUser() async {
    print("🌐 [API] GET /customer/auth/me");

    final response = await api.get("/customer/auth/me");

    print("⬅️ STATUS: ${response.statusCode}");
    print("⬅️ BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Kullanıcı bilgisi alınamadı");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // POST /customer/auth/update-profile
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> updateUser(UserModel data) async {
    print("🌐 [API] PUT /customer/profile");

    final body = {
      "first_name": data.firstName,
      "last_name": data.lastName,
      // Dökümanda email ve birth_date yazmıyor,
      // eğer hata alırsan sadece ad-soyad bırakabilirsin.
      "birth_date": data.birthDate,
    };

    // Artık 'put' metodu tanımlı olduğu için hata vermeyecek
    final response = await api.put("/customer/profile", body: body);

    print("⬅️ STATUS: ${response.statusCode}");
    print("⬅️ BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Profil güncellenemedi. Hata kodu: ${response.statusCode}");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // POST /customer/auth/send-email-otp
  // ----------------------------------------------------------------------
  @override
  Future<void> sendEmailVerification(String email) async {
    print("🌐 [API] POST /customer/auth/send-email-otp");
    print("➡️ EMAIL: $email");

    final response = await api.post(
      "/customer/auth/send-email-otp",
      body: {"email": email},
    );

    print("⬅️ STATUS: ${response.statusCode}");
    print("⬅️ BODY: ${response.body}");

    if (response.statusCode != 200 || jsonDecode(response.body)["success"] != true) {
      throw Exception("E-posta doğrulama kodu gönderilemedi");
    }
  }

// ----------------------------------------------------------------------
// POST /customer/auth/verify-email-otp
// ----------------------------------------------------------------------
  @override
  Future<UserModel> verifyEmailOtpCode(String email, String code) async {
    final response = await api.post(
      "/customer/auth/verify-email-otp",
      body: {"email": email, "code": code},
    );

    if (response.statusCode != 200) {
      throw Exception("OTP doğrulanamadı");
    }

    final decoded = jsonDecode(response.body);

    // 🔥 SORUN BURADAYDI: Backend data'yı null gönderiyor.
    // Eğer data null ise mevcut kullanıcıyı çekmek için /me çağrısı yapmalıyız
    // veya sadece başarılı kabul etmeliyiz.

    if (decoded["data"] == null) {
      // Backend güncel kullanıcıyı dönmüyorsa, biz manuel /me çağırıp güncel halini alalım
      return await fetchUser();
    }

    return UserModel.fromJson(decoded["data"]);
  }


  // ----------------------------------------------------------------------
  // POST /customer/auth/update-phone
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> updatePhoneNumber(String phone) async {
    print("🌐 [API] POST /customer/auth/update-phone");
    print("➡️ PHONE: $phone");

    final response =
    await api.post("/customer/auth/update-phone", body: {"phone": phone});

    print("⬅️ STATUS: ${response.statusCode}");
    print("⬅️ BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Telefon numarası güncellenemedi");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // POST /customer/profile/email/send-otp
  // ----------------------------------------------------------------------
  @override
   Future<void> sendEmailChangeOtp(String newEmail) async {
    print("🌐 [API] POST /customer/profile/email/send-otp");

    final response = await api.post(
      "/customer/profile/email/send-otp",
      body: {"email": newEmail},
    );

    if (response.statusCode != 200) {
      throw Exception("Kod gönderilemedi: ${response.body}");
    }
  }

  // ----------------------------------------------------------------------
  // POST /customer/profile/email/verify-otp
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> verifyEmailChangeOtp(String email, String code) async {
    print("🌐 [API] POST /customer/profile/email/verify-otp");

    final response = await api.post(
      "/customer/profile/email/verify-otp",
      body: {"email": email, "code": code},
    );

    if (response.statusCode != 200) {
      throw Exception("Kod doğrulanamadı.");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }


  // ----------------------------------------------------------------------
  // DELETE /customer/auth/delete
  // ----------------------------------------------------------------------
  @override
  Future<void> deleteAccount() async {
    print("🌐 [API] DELETE /customer/auth/delete");

    final response = await api.delete("/customer/auth/delete");

    print("⬅️ STATUS: ${response.statusCode}");
    print("⬅️ BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Hesap silinemedi");
    }
  }
}

// Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return UserRepositoryImpl(api);
});
