// lib/core/providers/dio_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/providers/auth_notifier.dart';
import '../../features/auth/domain/states/auth_state.dart';

// Varsayım: Auth Token'ı Shared Preferences'tan veya Auth Provider'dan okunuyor
// Auth Provider'ınızın yolu bu değilse lütfen düzeltin!

/// Uygulamanın temel API URL'si
const String _baseUrl = 'https://your-backend-api.com/api/v1'; // ⚠️ BURAYI KENDİ API ADRESİNİZLE DEĞİŞTİRİN

/// Dio instance'ını sağlayan ana provider
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    ),
  );

  // 🔒 Interceptor: Auth Token'ı her isteğe otomatik olarak ekler
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // AuthNotifier'dan token'ı alıyoruz
        final authState = ref.read(authNotifierProvider);

        // Eğer kullanıcı login olmuşsa ve bir token varsa, Header'a ekle
        if (authState.status == AuthStatus.authenticated && authState.user?.token != null) {
          options.headers['Authorization'] = 'Bearer ${authState.user!.token}';
        }

        return handler.next(options);
      },
      // Yanıt ve Hata yönetimi (İsteğe bağlı olarak eklenebilir)
      onError: (DioException e, handler) {
        // Örn: 401 Unauthorized hatası gelirse kullanıcıyı Login ekranına at.
        if (e.response?.statusCode == 401) {
          // Token süresi dolmuş veya geçersiz. Auth state'i 'unauthenticated' olarak ayarla.
          // NOT: Bu kısım GoRouter redirect mantığınızla da halledilebilir.
          // ref.read(authNotifierProvider.notifier).state = AuthState.unauthenticated();
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});