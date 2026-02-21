import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../account/domain/providers/user_notifier.dart';
import '../../../account/data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../states/auth_state.dart';

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref: ref,
    repo: ref.read(authRepositoryProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthRepository repo;

  // Google Sign In nesnesi (Web Client ID Selim'den gelecek olan ID)
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  late final Future<void> _googleInit = _googleSignIn.initialize(
    // Android tarafında özellikle gerekiyorsa (Selim’den gelecek)
    serverClientId: '172164156241-eou1ge6fjopjgjao8cbieg26pkju4g3q.apps.googleusercontent.com',

    // Web için gerekiyorsa:
    // clientId: '...',
  );

  AuthNotifier({
    required this.ref,
    required this.repo,
  }) : super(const AuthState.initial());


  // ---------------------------------------------------------------------------
  // GOOGLE LOGIN AKIŞI (Debug Log Destekli)
  // ---------------------------------------------------------------------------
  Future<bool> loginWithGoogle() async {
    debugPrint("🔵 [GOOGLE-SIGN-IN] Süreç başlatıldı...");

    state = state.copyWith(
      status: AuthStatus.loading,
      clearErrorMessage: true,
      clearSocialUserData: true,
    );

    try {
      debugPrint("🔍 [GOOGLE-SIGN-IN] Google seçim paneli açılıyor...");
      await _googleInit;

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        debugPrint("⚠️ [GOOGLE-SIGN-IN] Kullanıcı seçim yapmadan geri çıktı.");
        state = state.copyWith(
          status: AuthStatus.initial,
          clearErrorMessage: true,
          clearSocialUserData: true,
        );
        return false;
      }

      debugPrint("✅ [GOOGLE-SIGN-IN] Kullanıcı seçildi: ${googleUser.email}");

      debugPrint("🔑 [GOOGLE-SIGN-IN] idToken talep ediliyor...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("❌ [GOOGLE-SIGN-IN] HATA: idToken null döndü!");
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: "Google ID Token alınamadı.",
        );
        return false;
      }

      debugPrint("🚀 [GOOGLE-SIGN-IN] idToken alındı (İlk 20 hane): ${idToken.substring(0, 20)}...");

      debugPrint("📡 [BACKEND-VERIFY] Token backend'e gönderiliyor...");
      final userData = await repo.verifySocialToken(
        provider: 'google',
        idToken: idToken,
      );

      if (userData != null) {
        debugPrint("🎉 [BACKEND-VERIFY] BAŞARILI!");

        state = state.copyWith(
          status: AuthStatus.initial,
          socialUserData: userData,
          clearErrorMessage: true,
        );
        return true;
      }

    } on DioException catch (e) {
      final String msg = e.response?.data?['message'] ?? "Google doğrulama backend hatası.";
      debugPrint("🚫 [DIO-ERROR] Status: ${e.response?.statusCode} | Message: $msg");
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return false;
    } catch (e) {
      debugPrint("💥 [FATAL-ERROR] Beklenmedik hata: $e");
      state = state.copyWith(status: AuthStatus.error, errorMessage: "Sistem hatası: $e");
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER (Selim'in 4. Adımı - Google ID ile Kayıt)
  // ---------------------------------------------------------------------------
  Future<UserModel?> register({
    required String phone,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      // Eğer state içinde socialUserData varsa, google_id'yi oradan alıyoruz
      final String? googleId = state.socialUserData?['social_id'];

      final user = await repo.register(
        phone: phone,
        firstName: firstName,
        lastName: lastName,
        email: email,
        googleId: googleId, // Backend'e ek olarak gönderiyoruz
      );

      if (user != null) {
        // Normal login süreciyle aynı devam eder
        await ref.read(userNotifierProvider.notifier).saveUser(user);
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setIsNewUser(false);

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        return user;
      }

      state = state.copyWith(status: AuthStatus.error, errorMessage: "Kayıt tamamlanamadı.");
      return null;
    } on DioException catch (e) {
      final String msg = e.response?.data?['message'] ?? "Kayıt hatası.";
      state = state.copyWith(status: AuthStatus.error, errorMessage: msg);
      return null;
    }
  }


  Future<void> sendOtp({required String phone, required String purpose}) async {
    state = state.copyWith(status: AuthStatus.loading);
    debugPrint("📡 [OTP REQUEST] $phone ($purpose)");

    try {
      // Repository artık success: false durumunda hata fırlatıyor
      final bool ok = await repo.sendOtp(phone, purpose: purpose);

      if (ok) {
        debugPrint("✅ [OTP RESPONSE] Başarılı");
        state = const AuthState.otpSent();
      } else {
        // Burası artık neredeyse hiç tetiklenmez çünkü repo hata fırlatıyor
        state = const AuthState.error("Beklenmedik bir sorun oluştu.");
      }
    } on DioException catch (e) {
      // 🔥 Backend'den gelen o gerçek mesajı yakaladığımız yer:
      final String serverMessage = e.response?.data?['message'] ?? "İşlem başarısız oldu.";

      debugPrint("❌ [BACKEND ERROR] Message: $serverMessage");

      // UI'da (LoginScreen) snackbar'da görünecek mesaj bu:
      state = AuthState.error(serverMessage);
    } catch (e) {
      debugPrint("💥 [FATAL ERROR] $e");
      state = const AuthState.error("Bağlantı hatası: İnternetinizi kontrol edin.");
    }
  }

  void clearSocial() {
    state = state.copyWith(
      clearSocialUserData: true,
      clearErrorMessage: true,
      status: AuthStatus.initial,
    );
  }

  // ---------------------------------------------------------------------------
  // REGISTER/OTP DOĞRULAMA
  // ---------------------------------------------------------------------------
  Future<UserModel?> verifyOtpModel(String phone, String code, {bool isLogin = true}) async {
    debugPrint("🚀 [AUTH-FLOW] İşlem başladı. Tel: $phone | Mod: ${isLogin ? 'LOGIN' : 'REGISTER'}");
    state = const AuthState.loading();

    try {
      UserModel? user;

      // 1. ADIM: Backend İsteği
      if (isLogin) {
        // Kullanıcı mevcutsa giriş yap
        user = await repo.login(phone, code);
      } else {
        // Yeni kullanıcıysa OTP doğrula
        user = await repo.verifyOtp(phone, code);
      }

      // 2. ADIM: Başarılı Giriş Kontrolü
      if (user != null) {
        debugPrint("✅ [AUTH-SUCCESS] İşlem Başarılı. User: ${user.firstName ?? 'Yeni Kullanıcı'}");

        // Global kullanıcı bilgisini kaydet
        await ref.read(userNotifierProvider.notifier).saveUser(user);

        // Profil eksik mi kontrolü (İsim yoksa kullanıcı yeni kayıt aşamasındadır)
        final bool isProfileMissing = user.firstName == null ||
            user.firstName!.trim().isEmpty ||
            user.firstName == "null";

        // Uygulama durumlarını güncelle
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        await ref.read(appStateProvider.notifier).setIsNewUser(isProfileMissing);

        debugPrint("📢 [STATE] LoggedIn: true, NewUser: $isProfileMissing");

        state = const AuthState.authenticated();
        return user;
      }

      // 3. ADIM: Beklenmedik Boş Yanıt Durumu
      debugPrint("⚠️ [AUTH] İşlem başarısız: Repo null döndü.");
      state = const AuthState.error("Sunucudan geçerli bir yanıt alınamadı.");
      return null;

    } on DioException catch (e) {
      // 🎯 4. ADIM: Backend Hata Mesajını Yakalama
      // Loglarında gördüğümüz o meşhur "message" alanını buradan çekiyoruz
      final String serverMessage = e.response?.data?['message'] ?? "Kod doğrulanamadı, lütfen tekrar deneyin.";

      debugPrint("❌ [OTP-ERROR-BACKEND]: $serverMessage");

      // State'e "Geçersiz OTP" yerine backend'den gelen gerçek mesajı basıyoruz
      state = AuthState.error(serverMessage);
      return null;

    } catch (e) {
      // 5. ADIM: Yazılımsal veya Bağlantı Hataları
      debugPrint("❌ [AUTH-FATAL-ERROR] Hata: $e");
      state = AuthState.error("Beklenmedik bir hata oluştu: Lütfen internetinizi kontrol edin.");
      return null;
    }
  }


// ---------------------------------------------------------------------------
  // LOGIN (Eksiksiz & Akıllı Hata Yönetimi)
  // ---------------------------------------------------------------------------
  Future<UserModel?> login(String phone, String code) async {
    state = const AuthState.loading();
    try {
      final user = await repo.login(phone, code);

      if (user != null) {
        // Giriş başarılı
        await ref.read(appStateProvider.notifier).setLoggedIn(true);
        state = AuthState.authenticated(user);
        return user;
      }

      // User null geldiyse
      state = const AuthState.error("Kullanıcı bilgileri alınamadı.");
      return null;

    } on DioException catch (e) {
      // 🎯 Backend'den gelen mesajı yakalıyoruz: "Hatalı kod", "Hesap donduruldu" vb.
      final String serverMessage = e.response?.data?['message'] ?? "Giriş yapılamadı.";
      debugPrint("❌ [AUTH-LOGIN-ERROR]: $serverMessage");

      state = AuthState.error(serverMessage);
      return null;
    } catch (e) {
      debugPrint("💥 [AUTH-LOGIN-FATAL]: $e");
      state = const AuthState.error("Bağlantı hatası: Lütfen internetinizi kontrol edin.");
      return null;
    }
  }


  // ---------------------------------------------------------------------------
// /ME (Refactored: Uygulama Açılışında NewUser Temizliği)
// ---------------------------------------------------------------------------
  Future<bool> loadUserFromToken() async {
    debugPrint("📡 [AUTH] loadUserFromToken başlatıldı...");
    try {
      final user = await repo.me();

      if (user == null) {
        state = const AuthState.unauthenticated();
        return false;
      }

      // 1. Kullanıcıyı kaydet
      ref.read(userNotifierProvider.notifier).saveUser(user);

      // 🔥 2. DİNAMİK KONTROL: Uygulama her açıldığında profil durumunu kontrol et
      // Bu sayede başka cihazdaki profil tamamlama bilgisi buraya da yansır.
      final bool isReallyNew = user.firstName == null || user.firstName!.trim().isEmpty;
      await ref.read(appStateProvider.notifier).setIsNewUser(isReallyNew);

      debugPrint("📢 [AUTH LOAD] Profil Dolu mu?: ${!isReallyNew}");

      state = AuthState.authenticated(user);
      return true;
    } catch (e) {
      debugPrint("❌ [AUTH LOAD] Hata: $e");
      state = const AuthState.unauthenticated();
      return false;
    }
  }


  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------
  Future<void> logout() async {
    // API logout
    await repo.logout();

    // Token temizle
    await PrefsService.clearToken();

    // AppState reset
    ref.read(appStateProvider.notifier).resetAfterLogout();

    // UserState reset
    ref.read(userNotifierProvider.notifier).clearUser();

    // Auth state reset
    state = const AuthState.unauthenticated();

    debugPrint("🚀 LOGOUT COMPLETED");
  }

}
