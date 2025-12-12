import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../account/data/models/user_model.dart';
import '../../../../core/data/prefs_service.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository({Dio? dio})
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: "https://dailygood.dijicrea.net/api/v1",
        headers: {"Accept": "application/json"},
      ));

  Future<bool> sendOtp(String phone) async {
    debugPrint("🌐 [API] POST /customer/auth/send-otp");
    debugPrint("➡️ phone: $phone");

    try {
      final res = await _dio.post("/customer/auth/send-otp", data: {
        "phone": phone,
      });

      debugPrint("📩 STATUS: ${res.statusCode}");
      debugPrint("📩 DATA: ${res.data}");

      return res.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("❌ sendOtp ERROR STATUS: ${e.response?.statusCode}");
      debugPrint("❌ sendOtp ERROR DATA: ${e.response?.data}");
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String code) async {
    debugPrint("🌐 [API] POST /customer/auth/verify-otp");
    debugPrint("➡️ Gönderilen: { phone: $phone, code: $code }");

    try {
      final res = await _dio.post("/customer/auth/verify-otp", data: {
        "phone": phone,
        "code": code,
      });

      debugPrint("📩 [API] Response STATUS: ${res.statusCode}");
      debugPrint("📩 [API] Response DATA: ${res.data}");

      return res.data["success"] == true;

    } on DioException catch (e) {
      debugPrint("❌ [API] verifyOtp ERROR STATUS: ${e.response?.statusCode}");
      debugPrint("❌ [API] verifyOtp ERROR DATA: ${e.response?.data}");
      return false;
    }
  }


  Future<UserModel?> login(String phone, String code) async {
    try {
      final res = await _dio.post("/customer/auth/login", data: {
        "phone": phone,
        "code": code,
      });

      debugPrint("📦 Login Response raw: ${res.data}");

      // 1) JSON’u parçalıyoruz
      final data = res.data["data"];
      final token = data["token"];
      final customerJson = data["customer"];

      // 2) User modelini JSON’dan oluştur
      UserModel user = UserModel.fromJson(customerJson);

      // 3) Token'ı modele ekle (copyWith)
      user = user.copyWith(token: token);

      // 4) Token’ı kaydet
      if (token != null && token.isNotEmpty) {
        await PrefsService.saveToken(token);
        _dio.options.headers["Authorization"] = "Bearer $token";
        debugPrint("🔑 Token kaydedildi → $token");
      } else {
        debugPrint("⚠️ Token GELMEDİ → Backend login response kontrol edilmeli");
      }

      return user; // mevcut kullanıcı

    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Kullanıcı daha önce kayıt olmadı → yeni kullanıcı flow
        return null;
      }

      // Diğer tüm hatalar
      rethrow;
    }
  }



  Future<UserModel?> me() async {
    try {
      final token = await PrefsService.readToken();
      if (token == null) return null;

      _dio.options.headers["Authorization"] = "Bearer $token";
      final res = await _dio.get("/customer/auth/me");

      return UserModel.fromJson(res.data["data"]);
    } catch (_) {
      return null;
    }
  }

// ------------------------------------------------------------------
// 🆕 YENİ KULLANICI KAYDI (/customer/auth/register)
// Sadece dolu olan (non-null ve non-empty) alanları gönderir.
// ------------------------------------------------------------------
  Future<UserModel> registerUser(UserModel user) async {
    debugPrint("🌐 [API] POST /customer/auth/register (Yeni Kayıt)");

    // 1. ZORUNLU alanlarla data objesini başlat
    final data = <String, dynamic>{
      "phone": user.phone,
      "first_name": user.firstName,
      "last_name": user.lastName,
    };

    // 2. OPSİYONEL alanları kontrol ederek ekle

    // Eğer email boşsa geçici bir email ekle
    if (user.email == null || user.email!.isEmpty) {
      final phoneSafe = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
      data["email"] = "noemail+$phoneSafe@dailygood.app";
    }

    if (user.birthDate != null && user.birthDate!.isNotEmpty) {
      data["birth_date"] = user.birthDate;
    }

    if (user.latitude != null && user.longitude != null) {
      data["latitude"] = user.latitude;
      data["longitude"] = user.longitude;
    }

    if (user.fcmToken != null && user.fcmToken!.isNotEmpty) {
      data["fcm_token"] = user.fcmToken;
    }

    // 🔥 Artık data hazır → burada loglamak doğru
    debugPrint("➡️ GÖNDERİLEN JSON → $data");

    try {
      // API çağrısı
      final res = await _dio.post("/customer/auth/register", data: data);

      debugPrint("📩 STATUS → ${res.statusCode}");
      debugPrint("📥 RESPONSE BODY → ${res.data}");
      debugPrint("📤 REQUEST BODY → ${res.requestOptions.data}");

      final registeredUser =
      UserModel.fromJson(res.data["data"]["customer"]).copyWith(
        token: res.data["data"]["token"],
      );

      if (registeredUser.token != null && registeredUser.token!.isNotEmpty) {
        _dio.options.headers["Authorization"] =
        "Bearer ${registeredUser.token}";
      }

      return registeredUser;

    } on DioException catch (e) {
      debugPrint("❌ [API] registerUser ERROR STATUS: ${e.response?.statusCode}");
      debugPrint("❌ [API] registerUser ERROR DATA: ${e.response?.data}");
      debugPrint("📤 REQUEST BODY (HATA ANINDA) → ${e.requestOptions.data}");
      rethrow;
    }
  }



  Future<void> logout() async {
    try {
      await _dio.post("/customer/auth/logout");
    } catch (_) {}
    await PrefsService.clearToken();
  }
}


final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});