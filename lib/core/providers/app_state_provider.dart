import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/location/data/repository/location_repository.dart';
import 'dio_provider.dart';


// --------------------------------------------------------------------------
// 1. REPOSITORY PROVIDER
// --------------------------------------------------------------------------

final locationRepositoryProvider = Provider((ref) {
  return LocationRepository(ref.watch(dioProvider));
});


// --------------------------------------------------------------------------
// 2. STATE MODELİ (TÜM ALANLAR TAM)
// --------------------------------------------------------------------------

class AppState {
  final bool isLoggedIn;
  final bool isNewUser;
  final bool hasSeenProfileDetails;
  final bool hasSeenOnboarding;
  final bool hasSelectedLocation;

  final double? latitude;
  final double? longitude;

  const AppState({
    this.isLoggedIn = false,
    this.isNewUser = false,
    this.hasSeenProfileDetails = false,
    this.hasSeenOnboarding = false,
    this.hasSelectedLocation = false,
    this.latitude,
    this.longitude,
  });

  AppState copyWith({
    bool? isLoggedIn,
    bool? isNewUser,
    bool? hasSeenProfileDetails,
    bool? hasSeenOnboarding,
    bool? hasSelectedLocation,
    double? latitude,
    double? longitude,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isNewUser: isNewUser ?? this.isNewUser,
      hasSeenProfileDetails:
      hasSeenProfileDetails ?? this.hasSeenProfileDetails,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasSelectedLocation: hasSelectedLocation ?? this.hasSelectedLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}


// --------------------------------------------------------------------------
// 3. STATE NOTIFIER — TÜM METOTLAR TAM
// --------------------------------------------------------------------------

class AppStateNotifier extends StateNotifier<AppState> {
  final LocationRepository _locationRepository;
  final Ref ref;

  AppStateNotifier(this.ref, this._locationRepository)
      : super(const AppState()) {
    load();
  }

  // ---------------------------------------------------------
  // LOAD — SharedPreferences'tan başlat
  // ---------------------------------------------------------
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    state = state.copyWith(
      isLoggedIn: prefs.getBool("logged_in") ?? false,
      isNewUser: prefs.getBool("is_new_user") ?? false,
      hasSeenProfileDetails:
      prefs.getBool("seen_profile_details") ?? false,
      hasSeenOnboarding: prefs.getBool("seen_onboarding") ?? false,
      hasSelectedLocation:
      prefs.getBool("selected_location") ?? false,
      latitude: prefs.getDouble("user_lat"),
      longitude: prefs.getDouble("user_lng"),
    );
  }

  // ---------------------------------------------------------
  // LOGIN
  // ---------------------------------------------------------
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", value);

    state = state.copyWith(isLoggedIn: value);
  }

  // ---------------------------------------------------------
  // NEW USER
  // ---------------------------------------------------------
  Future<void> setIsNewUser(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_new_user", v);

    state = state.copyWith(isNewUser: v);
    debugPrint("🚀 [APP STATE] isNewUser → $v");
  }

  // ---------------------------------------------------------
  // PROFILE DETAILS STEP
  // ---------------------------------------------------------
  Future<void> setHasSeenProfileDetails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_profile_details", value);

    state = state.copyWith(hasSeenProfileDetails: value);
  }

  // ---------------------------------------------------------
  // ONBOARDING
  // ---------------------------------------------------------
  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", value);

    state = state.copyWith(hasSeenOnboarding: value);
  }

  // ---------------------------------------------------------
  // KONUM SEÇİMİ
  // ---------------------------------------------------------
  Future<void> setUserLocation(
      double lat,
      double lng, {
        String address = "Bilinmeyen Adres",
      }) async {
    final prefs = await SharedPreferences.getInstance();

    // 1) API
    try {
      final ok = await _locationRepository.updateCustomerLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );

      if (!ok) {
        debugPrint("❗ Konum API'ye kaydedilemedi");
      }
    } catch (e) {
      debugPrint("❌ Konum API hatası: $e");
    }

    // 2) Local storage
    await prefs.setDouble("user_lat", lat);
    await prefs.setDouble("user_lng", lng);
    await prefs.setBool("selected_location", true);

    // 3) State update
    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      hasSelectedLocation: true,
    );
  }
}


// --------------------------------------------------------------------------
// 4. PROVIDER
// --------------------------------------------------------------------------

final appStateProvider =
StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final locationRepo = ref.watch(locationRepositoryProvider);
  return AppStateNotifier(ref, locationRepo);
});
