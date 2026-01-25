import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/prefs_service.dart';
import '../router/app_router.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: "https://dailygood.dijicrea.net/api/v1", // ✅ Yeni Domain
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        "Accept": "application/json",
      },
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  // 🛡️ SSL HATASINI ÇÖZEN BYPASS KODU (Chrome'daki "Gelişmiş -> Devam Et" gibi)
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    },
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await PrefsService.readToken();

        print("──────────────────────────────");
        print("📡 API REQUEST");
        print("➡️ URL: ${options.method} ${options.baseUrl}${options.path}");

        if (token != null && token.isNotEmpty) {
          options.headers["Authorization"] = "Bearer $token";
          print("🔐 TOKEN EKLENDİ");
        }

        if (options.data != null) print("📤 BODY: ${options.data}");
        print("──────────────────────────────");

        handler.next(options);
      },
      onResponse: (r, h) {
        print("📥 API RESPONSE [${r.statusCode}] <- ${r.realUri.path}");
        h.next(r);
      },
      onError: (e, h) {
        print("❌ API ERROR [${e.response?.statusCode}]");
        print("💬 MESAJ: ${e.message}");
        print("📦 DATA: ${e.response?.data}");
        print("──────────────────────────────");
        // 🚀 MERKEZİ HATA YÖNETİMİ BURADA BAŞLIYOR
        // İnternet yoksa (SocketException) veya sunucuya bağlanılamıyorsa (Timeout)
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.error is SocketException) {

          rootNavigatorKey.currentState?.context.go('/global-error');
        }
        h.next(e);
      },
    ),
  );

  return dio;
});

