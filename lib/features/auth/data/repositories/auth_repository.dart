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

      // Başarılı → giriş yaptı
      final user = UserModel.fromJson(res.data["data"]);
      debugPrint("📦 Login Response raw: ${res.data}");

      if (user.token != null && user.token!.isNotEmpty) {
        await PrefsService.saveToken(user.token!);
        _dio.options.headers["Authorization"] = "Bearer ${user.token}";
      }

      return user; // eski kullanıcı

    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // ❗ KULLANICI KAYITLI DEĞİL → yeni kullanıcı
        return null;
      }

      // Diğer tüm hatalar
      rethrow;
    }
  }

/// Yeni kayıtlı kullanıcı olup olmadığını kontrol eder. henüz backend endpoint olmadığı için simülasyon kullanılır.
  /// final res = await _dio.post("/customer/auth/check-phone", data: {
  //   "phone": phone,
  // });
  // return res.statusCode == 200;
  Future<bool> checkPhone(String phone) async {
    debugPrint("🌐 [API] POST /customer/auth/check-phone (Simulated)");

    // Simülasyon: 05001112233 kayıtlı, diğerleri değil
    if (phone == "05001112233") {
      return true; // kayıtlı kullanıcı
    } else {
      return false; // yeni kullanıcı
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

    // E-posta
    if (user.email != null && user.email!.isNotEmpty) {
      data["email"] = user.email;
    }

    // Doğum Tarihi (UserModel'de birthDate string olarak tutulduğu varsayılır)
    if (user.birthDate != null && user.birthDate!.isNotEmpty) {
      data["birth_date"] = user.birthDate;
    }

    // Konum (Lat/Lng) - Her ikisi de 'null' DEĞİLSE gönder (isEmpty kontrolü kalktı)
    if (user.latitude != null && user.longitude != null) {
      // 'isNotEmpty' kontrolünü tamamen kaldırıyoruz, çünkü double'dır.
      // Not: Backend'e double olarak göndermeniz beklenir.
      data["latitude"] = user.latitude;
      data["longitude"] = user.longitude;
    }

    // FCM Token (String olduğu varsayılır, isNotEmpty kontrolü kalır)
    if (user.fcmToken != null && user.fcmToken!.isNotEmpty) {
      data["fcm_token"] = user.fcmToken;
    }

    // FCM Token
    if (user.fcmToken != null && user.fcmToken!.isNotEmpty) {
      data["fcm_token"] = user.fcmToken;
    }

    debugPrint("➡️ Gönderilen (Dinamik): $data"); // Gönderilen son JSON'u kontrol edin

    try {
      // API çağrısı
      final res = await _dio.post("/customer/auth/register", data: data);

      debugPrint("📩 [API] registerUser STATUS: ${res.statusCode}");
      // ... (Kalan başarı mantığı ve token kaydı aynı)

      final registeredUser = UserModel.fromJson(res.data["data"]["customer"]).copyWith(
        token: res.data["data"]["token"],
      );

      if (registeredUser.token != null) {
        _dio.options.headers["Authorization"] = "Bearer ${registeredUser.token}";
      }

      return registeredUser;

    } on DioException catch (e) {
      debugPrint("❌ [API] registerUser ERROR STATUS: ${e.response?.statusCode}");
      debugPrint("❌ [API] registerUser ERROR DATA: ${e.response?.data}");
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