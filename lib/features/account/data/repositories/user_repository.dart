import 'dart:convert';
import 'package:flutter/material.dart';
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

  @override
  Future<UserModel> fetchUser() async {
    final response = await api.get("/customer/auth/me");
    if (response.statusCode != 200) throw Exception("Kullanıcı bilgisi alınamadı");
    final decoded = jsonDecode(response.body);
    return UserModel.fromJson(decoded["data"]);
  }

  // ----------------------------------------------------------------------
  // BURASI KRİTİK: Backend sadece bu 3-4 alanı kabul ediyor.
  // ----------------------------------------------------------------------
  @override
  Future<UserModel> updateUser(UserModel data) async {
    final body = {
      "first_name": data.firstName,
      "last_name": data.lastName,
      "email": data.email,        // 👈 EKSİK OLAN 1
      "birth_date": data.birthDate, // 👈 FORMATI KONTROL EDİLMELİ
    };

    // 🔍 DEDEKTİF PRINT
    print("🔑 [REPO] Token kontrol ediliyor...");

    print("--------------------------------------------------");
    print("🚀 [REPO-DEBUG] API'YE GİDEN PAKET:");
    print("👉 First Name: ${body['first_name']}");
    print("👉 Last Name:  ${body['last_name']}");
    print("👉 Email:      ${body['email']}");
    print("👉 Birth Date: ${body['birth_date']}"); // Burası boş mu gidiyor bakacağız
    print("--------------------------------------------------");

    try {
      final response = await api.put("/customer/profile", body: body);

      print("📥 [REPO-DEBUG] BACKEND YANITI:");
      print("📡 [REPO] İstek Atıldı. Status: ${response.statusCode}");
      print("📡 [REPO] Yanıt Body: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final user = UserModel.fromJson(decoded["data"]);

        print("🎯 [REPO-DEBUG] Güncelleme Sonrası Gelen Veri: ${user.birthDate}");

        return user;

      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized: Token eksik veya geçersiz!");
      } else {
        throw Exception("Hata: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 [REPO-DEBUG] KRİTİK HATA: $e");
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification(String email) async {
    final response = await api.post("/customer/auth/send-email-otp", body: {"email": email});
    if (response.statusCode != 200) throw Exception("Kod gönderilemedi");
  }

  @override
  Future<UserModel> verifyEmailOtpCode(String email, String code) async {
    final response = await api.post("/customer/auth/verify-email-otp", body: {"email": email, "code": code});
    if (response.statusCode != 200) throw Exception("OTP doğrulanamadı");

    final decoded = jsonDecode(response.body);
    // Eğer backend data dönmezse güncel halini fetchUser ile alıyoruz
    if (decoded["data"] == null) return await fetchUser();
    return UserModel.fromJson(decoded["data"]);
  }

  @override
  Future<UserModel> updatePhoneNumber(String phone) async {
    final response = await api.post("/customer/auth/update-phone", body: {"phone": phone});
    if (response.statusCode != 200) throw Exception("Telefon güncellenemedi");
    return UserModel.fromJson(jsonDecode(response.body)["data"]);
  }

  @override
  Future<void> sendEmailChangeOtp(String newEmail) async {
    final response = await api.post("/customer/profile/email/send-otp", body: {"email": newEmail});
    if (response.statusCode != 200) throw Exception("Kod gönderilemedi");
  }

  @override
  Future<UserModel> verifyEmailChangeOtp(String email, String code) async {
    final response = await api.post("/customer/profile/email/verify-otp", body: {"email": email, "code": code});
    if (response.statusCode != 200) throw Exception("Kod doğrulanamadı.");
    return UserModel.fromJson(jsonDecode(response.body)["data"]);
  }

  @override
  Future<void> deleteAccount() async {
    final response = await api.delete("/customer/auth/delete");
    if (response.statusCode != 200) throw Exception("Hesap silinemedi");
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return UserRepositoryImpl(api);
});