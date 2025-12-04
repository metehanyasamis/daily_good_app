import 'package:flutter/material.dart'; // debugPrint için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

// 🌟 Konum API bağımlılıkları
import '../../features/location/data/repository/location_repository.dart';
import 'dio_provider.dart';

// --------------------------------------------------------------------------
// 1. REPOSITORY PROVIDER
// --------------------------------------------------------------------------

final locationRepositoryProvider = Provider((ref) {
  return LocationRepository(ref.watch(dioProvider));
});


// --------------------------------------------------------------------------
// 2. STATE MODELİ
// --------------------------------------------------------------------------

class AppState {
  final bool isLoggedIn;
  final bool hasSeenOnboarding;
  final bool hasSelectedLocation;
  final double? latitude;
  final double? longitude;
  final bool isNewUser;
  final bool hasSeenProfileDetails; // KRİTİK ALAN

  const AppState({
    this.isLoggedIn = false,
    this.hasSeenOnboarding = false,
    this.hasSelectedLocation = false,
    this.latitude,
    this.longitude,
    this.isNewUser = false,
    this.hasSeenProfileDetails = false,
  });

  AppState copyWith({
    bool? isLoggedIn,
    bool? hasSeenOnboarding,
    bool? hasSelectedLocation,
    double? latitude,
    double? longitude,
    bool? isNewUser,
    bool? hasSeenProfileDetails,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasSelectedLocation: hasSelectedLocation ?? this.hasSelectedLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isNewUser: isNewUser ?? this.isNewUser,
      hasSeenProfileDetails: hasSeenProfileDetails ?? this.hasSeenProfileDetails,
    );
  }
}


// --------------------------------------------------------------------------
// 3. STATE NOTIFIER VE BUSINESS LOGIC
// --------------------------------------------------------------------------

class AppStateNotifier extends StateNotifier<AppState> {
  final LocationRepository _locationRepository;
  final Ref ref;

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
      isNewUser: prefs.getBool("is_new_user") ?? false,
      hasSeenProfileDetails: prefs.getBool("seen_profile_details") ?? false,
    );
    // debugPrint("App State Loaded: $state");
  }

  /// ---------------------------------------------------------
  /// LOGIN, ONBOARDING, vs.
  /// ---------------------------------------------------------
  Future<void> setLoggedIn(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", v);

    state = state.copyWith(isLoggedIn: v);
  }

  Future<void> setNewUser(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_new_user", v);

    state = state.copyWith(isNewUser: v);
  }

  // hasSeenProfileDetails metodu
  Future<void> setHasSeenProfileDetails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_profile_details", value);

    debugPrint("🚦 [APP STATE] hasSeenProfileDetails güncelleniyor: $value");
    state = state.copyWith(hasSeenProfileDetails: value);
  }

  /// ---------------------------------------------------------
  /// ONBOARDING
  /// ---------------------------------------------------------
  Future<void> setOnboardingSeen(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", v);

    state = state.copyWith(hasSeenOnboarding: v);
  }

  /// ---------------------------------------------------------
  /// Konumu kaydet (Cihazdan veya Haritadan) ve API'ye gönder
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
  final locationRepository = ref.watch(locationRepositoryProvider);
  return AppStateNotifier(ref, locationRepository);
});