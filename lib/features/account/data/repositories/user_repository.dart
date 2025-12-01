import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

/// ----------------------------------------------------------------------
/// ABSTRACT REPOSITORY
/// ----------------------------------------------------------------------
abstract class UserRepository {
  Future<UserModel> fetchUser();                       // GET /me
  Future<UserModel> updateUser(UserModel data);        // POST /auth/update-profile
  Future<void> sendEmailVerification(String email);    // POST /auth/send-email-otp
  Future<UserModel> verifyEmailOtpCode(String otp);    // POST /auth/verify-email-otp
  Future<UserModel> updatePhoneNumber(String phone);   // POST /auth/update-phone
  Future<void> deleteAccount();                        // DELETE /users/delete
}

/// ----------------------------------------------------------------------
/// REAL IMPLEMENTATION — BACKEND ile %100 UYUMLU
/// ----------------------------------------------------------------------
class UserRepositoryImpl implements UserRepository {
  final ApiClient api;

  UserRepositoryImpl(this.api);

  // ----------------------------------------------------------------------
  // GET /me  →  "data" direkt user JSON
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> fetchUser() async {
    final response = await api.get("/me");

    if (response.statusCode != 200) {
      throw Exception("Kullanıcı bilgisi alınamadı");
    }

    final decoded = jsonDecode(response.body);
    final jsonUser = decoded["data"];

    return UserModel.fromJson(jsonUser);
  }

  // ----------------------------------------------------------------------
  // POST /auth/update-profile
  // Backend profil fields: first_name, last_name, email
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> updateUser(UserModel data) async {
    final body = {
      "first_name": data.firstName,
      "last_name": data.lastName,
      "email": data.email,
      "birth_date": data.birthDate,
    };

    final response = await api.post("/auth/update-profile", body: body);

    if (response.statusCode != 200) {
      throw Exception("Profil güncellenemedi");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // POST /auth/send-email-otp
  // ----------------------------------------------------------------------
  @override
  Future<void> sendEmailVerification(String email) async {
    final response = await api.post("/auth/send-email-otp", body: {
      "email": email,
    });

    if (response.statusCode != 200) {
      throw Exception("E-posta doğrulama kodu gönderilemedi");
    }
  }

  // ----------------------------------------------------------------------
  // POST /auth/verify-email-otp
  // Backend: return { success, message, data: user }
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> verifyEmailOtpCode(String otp) async {
    final response = await api.post("/auth/verify-email-otp", body: {
      "otp": otp,
    });

    if (response.statusCode != 200) {
      throw Exception("OTP doğrulanamadı");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // POST /auth/update-phone
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> updatePhoneNumber(String phone) async {
    final response = await api.post("/auth/update-phone", body: {
      "phone": phone,
    });

    if (response.statusCode != 200) {
      throw Exception("Telefon numarası güncellenemedi");
    }

    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // DELETE /users/delete
  // ----------------------------------------------------------------------
  @override
  Future<void> deleteAccount() async {
    final response = await api.delete("/users/delete");

    if (response.statusCode != 200) {
      throw Exception("Hesap silinemedi");
    }
  }
}

/// Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return UserRepositoryImpl(api);
});
