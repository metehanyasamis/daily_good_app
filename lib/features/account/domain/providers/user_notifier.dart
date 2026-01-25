import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../location/domain/address_notifier.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../states/user_state.dart';
import '../../../../core/data/prefs_service.dart';

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref: ref,
    repository: ref.read(userRepositoryProvider),
    authRepository: ref.read(authRepositoryProvider),
  );
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;
  final UserRepository repository;
  final AuthRepository authRepository;

  UserNotifier({
    required this.ref,
    required this.repository,
    required this.authRepository,
  }) : super(const UserState.initial());

  // Giriş sonrası veya me sonrası kullanıcıyı kaydet


  Future<void> saveUser(UserModel user) async {
    debugPrint("🚀 [SAVE_USER] Başladı: ${user.fullName}");

    // 1. LOKASYON VE ADRES (AYNI KALSIN)
    final double? lat = user.locationLat ?? user.latitude;
    final double? lng = user.locationLng ?? user.longitude;

    if (lat != null && lng != null) {
      debugPrint("📍 [SAVE_USER] Konum Set Ediliyor: $lat, $lng");
      await ref.read(appStateProvider.notifier)
          .setHasSelectedLocation(true, lat: lat, lng: lng);
      await ref.read(addressProvider.notifier).setFromMap(lat: lat, lng: lng);
    }

    // ✅ EMAIL VERIFIED TEK KAYNAK: BACKEND (user.isEmailVerified)
    debugPrint("📧 [SAVE_USER] Backend isEmailVerified: ${user.isEmailVerified}");

    // 3. STATE GÜNCELLEME (override yok)
    state = UserState.ready(user);
    debugPrint("✅ [SAVE_USER] State güncellendi (email verified backend'e bağlı).");
  }



  // Yeni kullanıcıyı locale kaydet (Token henüz yokken)
  void saveUserLocally(UserModel user) {
    state = UserState.ready(user);
    debugPrint("📌 [USER] saveUserLocally → ${user.phone}");
  }

  // Çıkış yap
  void clearUser() {
    PrefsService.clearToken();
    PrefsService.clearUserData();

    state = const UserState.initial();
    debugPrint("🧹 [USER] clearUser (Token ve User silindi, Mühür korundu)");
  }


  Future<void> loadUser({bool forceRefresh = true}) async {
    try {
      debugPrint("🔍 [LOAD_USER] İşlem Başladı...");

      // Yedek lokasyon/isim (bunu koruyabiliriz)
      final double? backupLat = state.user?.locationLat ?? state.user?.latitude;
      final double? backupLng = state.user?.locationLng ?? state.user?.longitude;
      final String? backupFullName = state.user?.fullName;

      debugPrint("🧩 [LOAD_USER] Yedek Konum: $backupLat, $backupLng | Yedek İsim: $backupFullName");

      if (state.user == null) {
        state = const UserState.loading();
      }

      // 🔄 BACKEND İSTEKLERİ
      final results = await Future.wait([
        repository.fetchMe(),    // doğrulama alanları (email_verified_at, phone_verified_at)
        repository.fetchUser(),  // istatistikler vs
      ]);

      final meUser = results[0];
      final profileUser = results[1];

      debugPrint("📧 [LOAD_USER] meUser.isEmailVerified: ${meUser.isEmailVerified}");
      debugPrint("📧 [LOAD_USER] profileUser.isEmailVerified: ${profileUser.isEmailVerified}");
      debugPrint("📱 [LOAD_USER] meUser.isPhoneVerified: ${meUser.isPhoneVerified}");

      // ✅ Email verified TEK KAYNAK: backend (meUser / profileUser hangisinde doğruysa)
      // Senin modelin email_verified_at’a bakıyor, fetchMe zaten bunu logluyor. :contentReference[oaicite:5]{index=5}
      final bool finalVerifiedStatus = meUser.isEmailVerified || profileUser.isEmailVerified;

      final finalUser = meUser.copyWith(
        isEmailVerified: finalVerifiedStatus, // ✅ sadece backend birleşimi
        // Lokasyon: backend yoksa yedek
        locationLat: meUser.locationLat ?? meUser.latitude ?? backupLat,
        locationLng: meUser.locationLng ?? meUser.longitude ?? backupLng,
        latitude: meUser.latitude ?? backupLat,
        longitude: meUser.longitude ?? backupLng,
        // Veri birleştirme
        statistics: profileUser.statistics ?? meUser.statistics,
        fullName: meUser.fullName ?? backupFullName ?? profileUser.fullName,
      );

      state = UserState.ready(finalUser);

      debugPrint("✅ [LOAD_USER] Tamamlandı.");
      debugPrint("📧 [LOAD_USER] Final EmailVerified: ${finalUser.isEmailVerified}");

      // Adres senkronizasyonu (aynı kalsın)
      final double? lat = finalUser.locationLat ?? finalUser.latitude;
      final double? lng = finalUser.locationLng ?? finalUser.longitude;

      if (lat != null && lng != null) {
        debugPrint("📍 [LOAD_USER] Adres senkronizasyonu yapılıyor...");
        ref.read(appStateProvider.notifier).setHasSelectedLocation(true, lat: lat, lng: lng);
        ref.read(addressProvider.notifier).setFromMap(lat: lat, lng: lng);
      }
    } catch (e) {
      debugPrint("❌ [LOAD_USER] KRİTİK HATA: $e");
      if (state.user == null) {
        state = UserState.error(e.toString());
      }
    }
  }


  // ------------------------------------------------------------------
  // TEK VE ANA GÜNCELLEME METODU (Düzeltilmiş Versiyon)
  // ------------------------------------------------------------------
  Future<void> updateUser(UserModel updated) async {
    final previousUser = state.user;
    final bool isNewUser = ref.read(appStateProvider).isNewUser;

    print("🚀 [NOTIFIER] Güncelleme Başladı. Yeni Kullanıcı: $isNewUser");
    print("📅 [NOTIFIER] Gönderilen Doğum Tarihi: ${updated.birthDate}");

    try {
      state = state.copyWith(status: UserStatus.loading);
      UserModel savedUser;

      if (isNewUser) {
        savedUser = await authRepository.registerUser(updated);
      } else {
        savedUser = await repository.updateUser(updated);
      }

      print("✅ [NOTIFIER] Backend'den Gelen Tarih: ${savedUser.birthDate}");
      state = UserState.ready(savedUser);
    } catch (e) {
      print("❌ [NOTIFIER] HATA: $e");
      state = previousUser != null ? UserState.ready(previousUser) : const UserState.initial();
      rethrow;
    }
  }

  // ------------------------------------------------------------------
  // 📧 E-POSTA DEĞİŞTİRME AKIŞI (Yeni Eklenenler)
  // ------------------------------------------------------------------

  // 1. OTP Kodu Gönder (Eksik olan metot buydu)
// 1. OTP Kodu Gönder (Hata mesajı yönetimi eklendi)
  Future<void> sendEmailChangeOtp(String newEmail) async {
    // Önce loading durumuna çek ve varsa eski hataları temizle
    state = state.copyWith(status: UserStatus.loading, errorMessage: null);

    try {
      print("🚀 [NOTIFIER] Email Change OTP İstendi: $newEmail");
      await repository.sendEmailChangeOtp(newEmail);

      // Başarılıysa durumu success yap (Sheet'te bir sonraki adıma geçmek için)
      state = state.copyWith(status: UserStatus.ready);
    } catch (e) {
      print("❌ [NOTIFIER] sendEmailChangeOtp Hata: $e");

      // Backend'den gelen "Geçerli bir e-posta adresi giriniz." mesajını yakala
      final cleanMessage = e.toString().replaceAll("Exception: ", "");

      // State'e hata mesajını yaz ki UI bunu görebilsin
      state = state.copyWith(
          status: UserStatus.error,
          errorMessage: cleanMessage
      );

      rethrow; // UI'daki try-catch'in de yakalaması için
    }
  }

  // 2. OTP Kodu Doğrula (E-posta değişimini tamamlar)
  Future<bool> verifyEmailChangeOtp(String email, String code) async {
    try {
      print("🔑 [NOTIFIER] Email Change OTP Doğrulanıyor: $code");
      // Repository'den gelen güncel kullanıcı modelini alıyoruz
      final updatedUser = await repository.verifyEmailChangeOtp(email, code);

      // State'i yeni kullanıcı bilgileriyle güncelle
      state = UserState.ready(updatedUser);
      print("✅ [NOTIFIER] Email Değişimi Başarılı!");
      return true;
    } catch (e) {
      print("❌ [NOTIFIER] verifyEmailChangeOtp Hata: $e");
      return false;
    }
  }

  // Email OTP işlemleri
  Future<void> sendEmailVerification(String email) async {
    await repository.sendEmailVerification(email);
  }

  Future<bool> verifyEmailOtp(String email, String otp) async {
    try {
      debugPrint("🔑 [VERIFY_OTP] Kod gönderiliyor... email=$email");

      final updatedUser = await repository.verifyEmailOtpCode(email, otp);

      debugPrint("✅ [VERIFY_OTP] verifyEmailOtpCode başarılı döndü.");
      debugPrint("📧 [VERIFY_OTP] updatedUser.isEmailVerified: ${updatedUser.isEmailVerified}");

      // ✅ Doğrulama sonrası GERÇEK veriyi backend’den tekrar çek
      debugPrint("🔄 [VERIFY_OTP] loadUser() ile backend doğrulaması yeniden okunuyor...");
      await loadUser();

      debugPrint("🏁 [VERIFY_OTP] loadUser() bitti. State EmailVerified: ${state.user?.isEmailVerified}");

      // Eğer hala false ise backend email_verified_at set etmiyordur.
      if (state.user?.isEmailVerified != true) {
        debugPrint("⚠️ [VERIFY_OTP] Doğrulama sonrası bile EmailVerified false. Backend email_verified_at set etmiyor olabilir!");
      }

      return true;
    } catch (e) {
      debugPrint("❌ [EMAIL_VERIFY] HATA: $e");
      return false;
    }
  }


  // Diğer işlemler
  Future<void> updatePhone(String phone) async {
    final user = await repository.updatePhoneNumber(phone);
    state = UserState.ready(user);
  }

  Future<void> deleteUserAccount() async {
    debugPrint("🚀 [NOTIFIER] Fonksiyon tetiklendi!");
    try {
      await repository.deleteAccount();
      debugPrint("✅ [NOTIFIER] Repo bitti.");
    } catch (e) {
      debugPrint("🚨 [NOTIFIER] Hata: $e");
      rethrow;
    }
  }
}