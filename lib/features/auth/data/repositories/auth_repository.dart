import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../../account/data/models/user_model.dart';
import '../../../../core/data/prefs_service.dart';

class AuthRepository {
  final Dio _dio;

  // ✅ Dio'yu dışarıdan (provider'dan) alıyoruz
  AuthRepository(this._dio);


  Future<bool> sendOtp(String phone, {required String purpose}) async {
    try {
      final response = await _dio.post('/customer/auth/send-otp', data: {
        'phone': phone,
        'purpose': purpose,
      });

      // 💡 KRİTİK NOKTA: Backend 200 dönse bile success false ise hata fırlat
      if (response.data['success'] == false) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      return response.data['success'] == true;
    } catch (e) {
      // Hatayı Notifier yakalasın diye olduğu gibi yukarı atıyoruz
      rethrow;
    }
  }


  Future<UserModel?> verifyOtp(String phone, String code) async {
    try {
      debugPrint("📡 [REPO] verifyOtp isteği atılıyor...");
      final res = await _dio.post("/customer/auth/verify-otp", data: {
        "phone": phone,
        "code": code,
      });

      // 💡 ÖNEMLİ: Backend 200 dönse bile success false ise manuel hata fırlat
      if (res.data["success"] == false) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
        );
      }

      final dynamic rawData = res.data["data"];
      debugPrint("📥 [REPO-RAW]: $rawData");

      final String? token = rawData["token"];
      final Map<String, dynamic>? customerJson = rawData["customer"];

      // Token varsa kaydet ve header'a ekle
      if (token != null && token.isNotEmpty) {
        await PrefsService.saveToken(token);
        _dio.options.headers["Authorization"] = "Bearer $token";
        debugPrint("🔑 [REPO] Token kaydedildi.");
      }

      if (customerJson != null) {
        debugPrint("✅ [REPO] Kullanıcı detayları bulundu.");
        return UserModel.fromJson(customerJson).copyWith(token: token);
      } else {
        debugPrint("⚠️ [REPO] Customer objesi yok, temel model dönülüyor.");
        return UserModel(id: "", phone: rawData["phone"] ?? phone, token: token);
      }

    } on DioException catch (e) {
      // 🎯 HATA BURADA: Hatayı yakalayıp return null DEMİYORUZ, rethrow yapıyoruz.
      // Böylece AuthNotifier bu hatayı yakalayıp içindeki mesajı okuyabilir.
      debugPrint("❌ [REPO-OTP-ERROR] Dio Hatası: ${e.response?.statusCode}");
      rethrow;
    } catch (e) {
      debugPrint("💥 [REPO-OTP-FATAL] Beklenmedik Hata: $e");
      rethrow;
    }
  }



  Future<UserModel?> login(String phone, String code) async {
    try {
      debugPrint("📡 [REPO] login isteği atılıyor...");
      final res = await _dio.post("/customer/auth/login", data: {
        "phone": phone,
        "code": code,
      });

      // 1. KONTROL: Backend success: false döndüyse hata fırlat
      if (res.data["success"] == false) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
        );
      }

      final data = res.data["data"];
      if (data == null) return null;

      final token = data["token"];
      final customerJson = data["customer"];

      if (customerJson != null) {
        UserModel user = UserModel.fromJson(customerJson).copyWith(token: token);

        if (token != null && token.isNotEmpty) {
          await PrefsService.saveToken(token);
          _dio.options.headers["Authorization"] = "Bearer $token";
          debugPrint("🔑 [REPO-LOGIN] Giriş başarılı, token kaydedildi.");
        }
        return user;
      }
      return null;
    } on DioException catch (e) {
      // 🎯 Hata mesajını Notifier yakalasın diye yukarı fırlatıyoruz
      debugPrint("❌ [REPO-LOGIN] Dio Hatası: ${e.response?.statusCode}");
      rethrow;
    } catch (e) {
      debugPrint("💥 [REPO-LOGIN] Beklenmedik Hata: $e");
      rethrow;
    }
  }

  Future<UserModel?> me() async {
    try {
      final token = await PrefsService.readToken();
      if (token == null) return null;
      _dio.options.headers["Authorization"] = "Bearer $token";

      // 🔥 KESİN ÇÖZÜM: Sunucuya sadece 8 saniye süre tanı.
      // 8 saniyede cevap vermezse Splash kilitlenmesin, null dönsün ve geçsin.
      final res = await _dio.get("/customer/auth/me").timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint("⏰ [TIMEOUT] /me isteği 8 saniyede yanıt vermedi.");
          throw Exception("Timeout");
        },
      );

      return UserModel.fromJson(res.data["data"]);
    } catch (e) {
      debugPrint("🚨 [AUTH REPO] /me hatası: $e");
      return null;
    }
  }


  Future<UserModel> registerUser(UserModel user) async {
    try {
      final data = {
        "phone": user.phone,
        "first_name": user.firstName,
        "last_name": user.lastName,
        "email": user.email,
        "birth_date": user.birthDate
      };

      final res = await _dio.post(
        "/customer/auth/register",
        data: data,
        options: Options(validateStatus: (status) => true),
      );

      if (res.data["success"] == true) {
        final responseData = res.data["data"];
        final String? newToken = responseData["token"];
        final customerJson = responseData["customer"];

        if (newToken != null) {
          await PrefsService.saveToken(newToken);
          _dio.options.headers["Authorization"] = "Bearer $newToken";
        }
        return UserModel.fromJson(customerJson).copyWith(token: newToken);
      } else {
        throw Exception(res.data["message"] ?? "Kayıt başarısız");
      }
    } catch (e) {
      rethrow;
    }
  }

// ---------------------------------------------------------------------------
  // SOSYAL TOKEN DOĞRULAMA (Google/Apple Adım 1)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> verifySocialToken({
    required String provider,
    required String idToken,
  }) async {
    final res = await _dio.post(
      '/customer/auth/social/verify-token',
      data: {
        'provider': provider,
        'id_token': idToken,
      },
    );

    if (res.data['success'] != true) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
        error: 'Social token verification failed',
      );
    }

    final data = res.data['data'];
    if (data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    }

    return Map<String, dynamic>.from(data);
  }

  // ---------------------------------------------------------------------------
  // KAYIT OL (Adım 4 - İsmi Notifier ile eşitledik: register)
  // ---------------------------------------------------------------------------
  Future<UserModel?> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String email,
    String? googleId,
    String? appleId,
  }) async {
    try {
      final data = {
        "phone": phone,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        if (googleId != null) "google_id": googleId,
        if (appleId != null) "apple_id": appleId,
      };

      final res = await _dio.post("/customer/auth/register", data: data);

      if (res.data["success"] == true) {
        final responseData = res.data["data"];
        final String? newToken = responseData["token"];

        if (newToken != null) {
          await PrefsService.saveToken(newToken);
          _dio.options.headers["Authorization"] = "Bearer $newToken";
        }
        return UserModel.fromJson(responseData["customer"]).copyWith(token: newToken);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try { await _dio.post("/customer/auth/logout"); } catch (_) {}
    await PrefsService.clearToken();
  }
}

// ✅ Provider'ı güncelledik: dioProvider'ı dinliyor
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});