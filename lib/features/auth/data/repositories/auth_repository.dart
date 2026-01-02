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
      return response.data['success'] == true;
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /*
  Future<UserModel?> verifyOtp(String phone, String code) async {
    try {
      final res = await _dio.post("/customer/auth/verify-otp", data: {
        "phone": phone,
        "code": code,
      });

      if (res.data["success"] == true) {
        final dynamic body = res.data["data"] ?? res.data;

        debugPrint("🔍 [OTP_RAW_DATA]: $body");

        final String? token = body["token"];
        final Map<String, dynamic>? userJson = body["customer"] ?? body["user"];

        if (userJson != null) {
          debugPrint("📱 [PHONE_STATUS_IN_JSON]: ${userJson['phone_verified_at']}");
          UserModel user = UserModel.fromJson(userJson).copyWith(token: token);
          if (token != null) {
            await PrefsService.saveToken(token);
            _dio.options.headers["Authorization"] = "Bearer $token";
          }
          return user;
        } else {
          return UserModel(id: "", phone: body["phone"] ?? phone, token: null);
        }
      }
      return null;
    } catch (e) {
      debugPrint("💥 verifyOtp Hata: $e");
      return null;
    }
  }

  Future<UserModel?> login(String phone, String code) async {
    try {
      final res = await _dio.post("/customer/auth/login", data: {
        "phone": phone,
        "code": code,
      });

      final data = res.data["data"];
      final token = data["token"];
      final customerJson = data["customer"];

      UserModel user = UserModel.fromJson(customerJson).copyWith(token: token);

      if (token != null && token.isNotEmpty) {
        await PrefsService.saveToken(token);
        _dio.options.headers["Authorization"] = "Bearer $token";
      }
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

   */

  // features/auth/data/repositories/auth_repository.dart

  Future<UserModel?> verifyOtp(String phone, String code) async {
    try {
      debugPrint("📡 [REPO] verifyOtp isteği atılıyor...");
      final res = await _dio.post("/customer/auth/verify-otp", data: {
        "phone": phone,
        "code": code,
      });

      if (res.data["success"] == true) {
        final dynamic rawData = res.data["data"];
        debugPrint("📥 [REPO-RAW]: $rawData");

        // Dökümana göre token ve customer data'nın içinde
        final String? token = rawData["token"];
        final Map<String, dynamic>? customerJson = rawData["customer"];

        if (customerJson != null) {
          debugPrint("✅ [REPO] Kullanıcı detayları bulundu: ${customerJson['first_name']}");

          // UserModel.fromJson artık customer datasını alıyor
          UserModel user = UserModel.fromJson(customerJson).copyWith(token: token);

          if (token != null && token.isNotEmpty) {
            await PrefsService.saveToken(token);
            _dio.options.headers["Authorization"] = "Bearer $token";
            debugPrint("🔑 [REPO] Token kaydedildi.");
          }
          return user;
        } else {
          // 🚨 KRİTİK: Eğer customer yoksa sadece telefonla boş model dönüyoruz
          debugPrint("⚠️ [REPO] Customer objesi gelmedi, sadece telefon var.");
          return UserModel(id: "", phone: rawData["phone"] ?? phone, token: token);
        }
      }
      return null;
    } catch (e) {
      debugPrint("💥 [REPO] verifyOtp Hata: $e");
      return null;
    }
  }

  /*
  Future<UserModel?> login(String phone, String code) async {
    try {
      debugPrint("📡 [REPO] login isteği atılıyor...");
      final res = await _dio.post("/customer/auth/login", data: {
        "phone": phone,
        "code": code,
      });

      // Backend dökümanına göre: { success: true, data: { token: "...", customer: { ... } } }
      final data = res.data["data"];
      final token = data["token"];
      final customerJson = data["customer"];

      debugPrint("📥 [REPO-LOGIN] Customer: $customerJson");

      if (customerJson != null) {
        UserModel user = UserModel.fromJson(customerJson).copyWith(token: token);

        if (token != null && token.isNotEmpty) {
          await PrefsService.saveToken(token);
          _dio.options.headers["Authorization"] = "Bearer $token";
        }
        return user;
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ [REPO-LOGIN] Dio Hatası: ${e.response?.statusCode}");
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

   */


  Future<UserModel?> login(String phone, String code) async {
    try {
      debugPrint("📡 [REPO] login isteği atılıyor...");
      final res = await _dio.post("/customer/auth/login", data: {
        "phone": phone,
        "code": code,
      });

      // 1. KONTROL: Response veya response.data null mı?
      if (res.data == null || res.data["data"] == null) {
        debugPrint("⚠️ [REPO-LOGIN] Sunucudan boş veya hatalı veri geldi.");
        return null;
      }

      final data = res.data["data"];

      // 2. KONTROL: Token ve customerJson var mı?
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
      // 3. KONTROL: 404 veya diğer hata kodlarını burada yakala
      debugPrint("❌ [REPO-LOGIN] Dio Hatası: ${e.response?.statusCode}");
      debugPrint("💬 [REPO-LOGIN] Hata Mesajı: ${e.response?.data?['message']}");

      if (e.response?.statusCode == 404) {
        // Kullanıcı bulunamadı veya yanlış endpoint
        return null;
      }
      rethrow;
    } catch (e) {
      debugPrint("💥 [REPO-LOGIN] Beklenmedik Hata: $e");
      return null;
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

  /*
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

   */
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