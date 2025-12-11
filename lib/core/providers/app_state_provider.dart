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
// 2. STATE MODELİ
// --------------------------------------------------------------------------

class AppState {
  final bool isInitialized;        // ✅ Splash sonrası hazır mı?
  final bool isLoggedIn;
  final bool isNewUser;
  final bool hasSeenIntro;         // ✅ Intro ekranını gördü mü?
  final bool hasSeenProfileDetails;
  final bool hasSelectedLocation;
  final bool hasSeenOnboarding;

  final double? latitude;
  final double? longitude;

  const AppState({
    this.isInitialized = false,
    this.isLoggedIn = false,
    this.isNewUser = false,
    this.hasSeenIntro = false,
    this.hasSeenProfileDetails = false,
    this.hasSeenOnboarding = false,
    this.hasSelectedLocation = false,
    this.latitude,
    this.longitude,
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isLoggedIn,
    bool? isNewUser,
    bool? hasSeenIntro,
    bool? hasSeenProfileDetails,
    bool? hasSeenOnboarding,
    bool? hasSelectedLocation,
    double? latitude,
    double? longitude,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isNewUser: isNewUser ?? this.isNewUser,
      hasSeenIntro: hasSeenIntro ?? this.hasSeenIntro,
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
// 3. STATE NOTIFIER
// --------------------------------------------------------------------------

class AppStateNotifier extends StateNotifier<AppState> {
  final LocationRepository _locationRepository;
  final Ref ref;

  AppStateNotifier(this.ref, this._locationRepository)
      : super(const AppState());

  // ---------------------------------------------------------
  // LOAD — SharedPreferences'tan başlat (Splash çağıracak)
  // ---------------------------------------------------------
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    // PREFS'TEN OKU
    final token = prefs.getString("auth_token");
    final loggedIn = prefs.getBool("logged_in") ?? false;
    final isNewUser = prefs.getBool("is_new_user") ?? false;

    // -------------------------------------------------------
    // 🔥 TOKEN YOKSA → logged_in ve is_new_user ZORLA FALSE
    // -------------------------------------------------------
    bool safeLoggedIn = loggedIn;
    bool safeNewUser = isNewUser;

    if (token == null || token.isEmpty) {
      safeLoggedIn = false;
      safeNewUser = false;

      // Eski bozuk prefs değerlerini temizle
      await prefs.setBool("logged_in", false);
      await prefs.setBool("is_new_user", false);
    }

    state = state.copyWith(
      isInitialized: true,
      isLoggedIn: safeLoggedIn,
      isNewUser: safeNewUser,
      hasSeenIntro: prefs.getBool("seen_intro") ?? false,
      hasSeenProfileDetails: prefs.getBool("seen_profile_details") ?? false,
      hasSeenOnboarding: prefs.getBool("seen_onboarding") ?? false,
      hasSelectedLocation: prefs.getBool("selected_location") ?? false,
      latitude: prefs.getDouble("user_lat"),
      longitude: prefs.getDouble("user_lng"),
    );

    debugPrint("✅ [APP STATE] load() tamamlandı: "
        "token=${token != null && token.isNotEmpty}, "
        "loggedIn=$safeLoggedIn, newUser=$safeNewUser");
  }


  // ---------------------------------------------------------
  // LOGIN FLAG
  // ---------------------------------------------------------
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", value);
    state = state.copyWith(isLoggedIn: value);
  }

  // ---------------------------------------------------------
  // LOGOUT RESET
  // ---------------------------------------------------------
  Future<void> resetAfterLogout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("logged_in", false);
    await prefs.setBool("is_new_user", false);
    await prefs.setBool("seen_profile_details", false);
    await prefs.setBool("seen_onboarding", false);
    await prefs.setBool("selected_location", false);
    await prefs.remove("auth_token");

    state = const AppState(
      isInitialized: true,
      isLoggedIn: false,
      isNewUser: false,
      hasSeenIntro: true,
      hasSeenProfileDetails: false,
      hasSelectedLocation: false,
      hasSeenOnboarding: false,
      latitude: null,
      longitude: null,
    );
  }


  // ---------------------------------------------------------
  // NEW USER FLAG
  // ---------------------------------------------------------
  Future<void> setIsNewUser(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_new_user", v);
    state = state.copyWith(isNewUser: v);
    debugPrint("🚀 [APP STATE] isNewUser → $v");
  }

  // ---------------------------------------------------------
  // TOKEN ekleme
  // ---------------------------------------------------------
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
    state = state.copyWith(); // trigger rebuild
  }

  // ---------------------------------------------------------
  // INTRO FLAG
  // ---------------------------------------------------------
  Future<void> setHasSeenIntro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_intro", value);
    state = state.copyWith(hasSeenIntro: value);
  }

  // ---------------------------------------------------------
  // PROFILE DETAILS FLAG
  // ---------------------------------------------------------
  Future<void> setHasSeenProfileDetails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_profile_details", value);
    state = state.copyWith(hasSeenProfileDetails: value);
  }

  // ---------------------------------------------------------
  // ONBOARDING FLAG
  // ---------------------------------------------------------
  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", value);
    state = state.copyWith(hasSeenOnboarding: value);
  }


  // ---------------------------------------------------------
  // KONUM SEÇİMİ
  // ---------------------------------------------------------
  Future<bool> setUserLocation(
      double lat,
      double lng, {
        String address = "Bilinmeyen Adres",
      }) async {
    final prefs = await SharedPreferences.getInstance();

    bool apiOk = false;

    try {
      apiOk = await _locationRepository.updateCustomerLocation(
        latitude: lat,
        longitude: lng,
        address: address,
      );

      if (!apiOk) {
        debugPrint("❗ Konum API'ye kaydedilemedi (false döndü)");
      }
    } catch (e) {
      debugPrint("❌ Konum API hatası: $e");
    }

    if (!apiOk) {
      // burada istersen kullanıcıya snackbar da gösterebilirsin
      return false;
    }

    // Ancak API 200 OK ise:
    await prefs.setDouble("user_lat", lat);
    await prefs.setDouble("user_lng", lng);
    await prefs.setBool("selected_location", true);

    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      hasSelectedLocation: true,
    );
    return true;
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

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(appStateProvider, (_, __) {
      notifyListeners(); // router burada tetiklenecek
    });
  }

  final Ref ref;
}