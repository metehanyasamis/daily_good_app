import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // debugPrint için

// 🌟 Konum API bağımlılıkları
import '../../features/location/data/repository/location_repository.dart';
import 'dio_provider.dart'; // Dio'yu almak için

// --------------------------------------------------------------------------
// 1. REPOSITORY PROVIDER
// --------------------------------------------------------------------------

// 🌟 LocationRepository için Provider (Artık AppState içinde değil, dışarıda)
final locationRepositoryProvider = Provider((ref) {
  // Dio Provider'dan Dio örneğini alır ve Repository'ye verir
  return LocationRepository(ref.watch(dioProvider));
});


// --------------------------------------------------------------------------
// 2. STATE MODELİ
// --------------------------------------------------------------------------

class AppState {
  final bool isLoggedIn;
  final bool hasSeenOnboarding;
  final bool hasSelectedLocation; // kullanıcı konum seçti mi?
  final double? latitude;          // seçilen konum
  final double? longitude;
  final bool isNewUser;

  const AppState({
    this.isLoggedIn = false,
    this.hasSeenOnboarding = false,
    this.hasSelectedLocation = false,
    this.latitude,
    this.longitude,
    this.isNewUser = false,
  });

  AppState copyWith({
    bool? isLoggedIn,
    bool? hasSeenOnboarding,
    bool? hasSelectedLocation,
    double? latitude,
    double? longitude,
    bool? isNewUser,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasSelectedLocation: hasSelectedLocation ?? this.hasSelectedLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isNewUser: isNewUser ?? this.isNewUser,
    );
  }
}


// --------------------------------------------------------------------------
// 3. STATE NOTIFIER VE BUSINESS LOGIC
// --------------------------------------------------------------------------

class AppStateNotifier extends StateNotifier<AppState> {
  // 🌟 Repository'yi enjekte et
  final LocationRepository _locationRepository;
  final Ref ref;

  // 🌟 Constructor, hem Ref hem de LocationRepository alır
  AppStateNotifier(this.ref, this._locationRepository) : super(const AppState()) {
    load();
  }

  /// ---------------------------------------------------------
  /// LOAD — tüm ayarları SharedPreferences'tan yükle
  /// ---------------------------------------------------------
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final lat = prefs.getDouble("user_lat");
    final lng = prefs.getDouble("user_lng");

    state = state.copyWith(
      isLoggedIn: prefs.getBool("logged_in") ?? false,
      hasSeenOnboarding: prefs.getBool("seen_onboarding") ?? false,
      hasSelectedLocation: prefs.getBool("selected_location") ?? false,
      latitude: lat,
      longitude: lng,
    );
  }

  /// ---------------------------------------------------------
  /// LOGIN, ONBOARDING, vs. (AYNI KALDI)
  /// ---------------------------------------------------------
  Future<void> setLoggedIn(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", v);

    state = state.copyWith(isLoggedIn: v);
  }

  void setNewUser(bool val) {
    state = state.copyWith(isNewUser: val);
  }

  Future<void> setOnboardingSeen(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", v);

    state = state.copyWith(hasSeenOnboarding: v);
  }

  // setLocationSelected metodu yerine doğrudan setUserLocation kullanmak daha iyi.
  // Bu metodu koruyoruz ama kullanımı setUserLocation'a devredilmeli.
  Future<void> setLocationSelected(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("selected_location", v);

    state = state.copyWith(hasSelectedLocation: v);
  }

  /// ---------------------------------------------------------
  /// Kullanıcı konum izni verdi mi? (info screen)
  /// Bu metot sadece izni kaydetmeli, koordinatları değil.
  /// ---------------------------------------------------------
  Future<void> setLocationAccess(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("selected_location", v);

    state = state.copyWith(
      hasSelectedLocation: v,
    );
  }

  /// ---------------------------------------------------------
  /// 📍 Konumu kaydet (Cihazdan veya Haritadan) ve API'ye gönder (YENİ)
  /// ---------------------------------------------------------
  Future<void> setUserLocation(double lat, double lng, {String address = "Bilinmeyen Adres"}) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. API Güncellemesi
    try {
      final success = await _locationRepository.updateCustomerLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );

      if (success) {
        debugPrint('✅ Konum API\'ye başarıyla kaydedildi.');
      } else {
        debugPrint('❗ Konum API\'ye kaydedilemedi, ancak lokal state güncel.');
      }
    } catch (e) {
      debugPrint('❌ Konum API\'ye kaydetme hatası: $e');
      // Hata olsa bile lokal durumu ve tercihleri güncelleyelim.
    }

    // 2. SharedPreferences Güncellemesi
    await prefs.setDouble("user_lat", lat);
    await prefs.setDouble("user_lng", lng);
    await prefs.setBool("selected_location", true); // Konum seçildi olarak işaretle

    // 3. Lokal State Güncellemesi
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      hasSelectedLocation: true,
    );
  }
}


// --------------------------------------------------------------------------
// 4. MAIN PROVIDER TANIMI
// --------------------------------------------------------------------------

final appStateProvider =
StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  // 🌟 Notifier'ı oluştururken LocationRepository'yi enjekte et
  final locationRepository = ref.watch(locationRepositoryProvider);
  return AppStateNotifier(ref, locationRepository);
});