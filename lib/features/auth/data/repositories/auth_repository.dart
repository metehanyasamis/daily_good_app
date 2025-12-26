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

// auth_repository.dart içindeki sendOtp metodunu şu şekilde güncelle:
  Future<bool> sendOtp(String phone, {required String purpose}) async {
    try {
      final response = await _dio.post('/customer/auth/send-otp', data: {
        'phone': phone,
        'purpose': purpose,
      });
      return response.data['success'] == true;
    } on DioException catch (e) {
      // 💡 KRİTİK NOKTA: Hatayı yutma, yukarı fırlat ki Notifier mesajı alabilsin!
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> verifyOtp(String phone, String code) async {
    try {
      final res = await _dio.post("/customer/auth/verify-otp", data: {
        "phone": phone,
        "code": code,
      });

      // 1. Backend isteği kabul etti mi?
      if (res.data["success"] == true) {
        final dynamic body = res.data["data"] ?? res.data;
        final String? token = body["token"];
        final Map<String, dynamic>? userJson = body["customer"] ?? body["user"];

        if (userJson != null) {
          // DURUM A: Mevcut kullanıcı (Hemen token kaydet)
          UserModel user = UserModel.fromJson(userJson).copyWith(token: token);
          if (token != null) {
            await PrefsService.saveToken(token);
            _dio.options.headers["Authorization"] = "Bearer $token";
          }
          return user;
        } else {
          // DURUM B: Yeni kullanıcı (Logundaki durum!)
          // Token yok, sorun değil. Profil sayfasına gitmesi için geçici model dön:
          return UserModel(
            id: "",
            phone: body["phone"] ?? phone, // Backend'den gelen telefonu al
            token: null,
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint("💥 [CRITICAL ERROR] verifyOtp: $e");
      return null;
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
    // 1. BU SATIRI GÖRMEK ZORUNDAYIZ
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print("🚨 [CRITICAL-DEBUG] REGISTER METODU TETİKLENDİ!");
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

    try {
      // Veriyi hazırla
      final data = <String, dynamic>{
        "phone": user.phone,
        "first_name": user.firstName,
        "last_name": user.lastName,
        "email": user.email,
        "birth_date": user.birthDate
      };

      // 2. İSTEK ATILMADAN HEMEN ÖNCE
      print("🚀 [CRITICAL-DEBUG] API'ye gidiliyor... Data: $data");

      final res = await _dio.post(
        "/customer/auth/register",
        data: data,
        options: Options(
          headers: {"Authorization": ""}, // Token kontrolünü burada sıfırlıyoruz
          validateStatus: (status) => true, // Hata kodlarını (401, 422) yakalamamızı sağlar
        ),
      );

      // 3. CEVAP GELDİĞİNDE
      print("📥 [CRITICAL-DEBUG] Status: ${res.statusCode}");
      print("📥 [CRITICAL-DEBUG] Body: ${res.data}");

      if (res.data["success"] == true) {
        final responseData = res.data["data"];
        final String? newToken = responseData["token"];
        final customerJson = responseData["customer"];

        if (newToken != null) {
          await PrefsService.saveToken(newToken);
          _dio.options.headers["Authorization"] = "Bearer $newToken";
        }

        print("✅ [CRITICAL-DEBUG] Register Başarılı!");
        return UserModel.fromJson(customerJson).copyWith(token: newToken);
      } else {
        print("❌ [CRITICAL-DEBUG] Backend reddetti: ${res.data["message"]}");
        throw Exception(res.data["message"] ?? "Kayıt başarısız");
      }
    } catch (e) {
      // 4. EĞER BİR YERDE PATLARSA MUTLAKA BURAYA DÜŞER
      print("💥 [CRITICAL-DEBUG] YAKALANAN HATA: $e");
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