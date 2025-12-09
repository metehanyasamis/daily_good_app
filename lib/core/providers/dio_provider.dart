import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: "https://dailygood.dijicrea.net/api/v1",  // ← DÜZELTİLDİ
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        "Accept": "application/json",
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await PrefsService.readToken();

        print("──────────────────────────────");
        print("📡 API REQUEST");
        print("➡️ URL: ${options.method} ${options.baseUrl}${options.path}");

        if (options.data != null) {
          print("📤 BODY: ${options.data}");
        }

        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
          print("🔐 TOKEN header eklendi → $token");
        } else {
          print("⚠️ TOKEN YOK (HEADER EKLENMEDİ)");
        }

        print("📑 HEADERS: ${options.headers}");
        print("──────────────────────────────");

        handler.next(options);
      },

      onResponse: (r, h) {
        print("📥 API RESPONSE → ${r.statusCode}");
        print(r.data);
        print("──────────────────────────────");
        h.next(r);
      },

      onError: (e, h) {
        print("❌ API ERROR");
        print("STATUS: ${e.response?.statusCode}");
        print("DATA: ${e.response?.data}");
        print("MESSAGE: ${e.message}");
        print("──────────────────────────────");
        h.next(e);
      },
    ),
  );

  return dio;
});
