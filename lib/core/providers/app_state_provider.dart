import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/location/data/repository/location_repository.dart';
import '../../features/location/domain/address_notifier.dart';
import 'dio_provider.dart';


// --------------------------------------------------------------------------
// REPOSITORY PROVIDER
// --------------------------------------------------------------------------
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository(ref.watch(dioProvider));
});


// --------------------------------------------------------------------------
// APP STATE MODEL
// --------------------------------------------------------------------------
@immutable
class AppState {
  final bool isInitialized;
  final bool isLoggedIn;
  final bool isNewUser;

  final bool hasSeenIntro;
  final bool hasSeenProfileDetails;
  final bool hasSeenOnboarding;
  final bool hasSelectedLocation;

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
// APP STATE NOTIFIER
// --------------------------------------------------------------------------
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(this.ref, this._locationRepository)
      : super(const AppState());

  final Ref ref;
  final LocationRepository _locationRepository;

  // ------------------------------------------------------------------------
  // INIT (Splash çağırır)
  // ------------------------------------------------------------------------
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString("auth_token");

    bool loggedIn = prefs.getBool("logged_in") ?? false;
    bool newUser = prefs.getBool("is_new_user") ?? false;

    // 🔒 TOKEN YOKSA → HER ŞEYİ TEMİZLE
    if (token == null || token.isEmpty) {
      loggedIn = false;
      newUser = false;

      await prefs.setBool("logged_in", false);
      await prefs.setBool("is_new_user", false);
    }

    state = state.copyWith(
      isInitialized: true,
      isLoggedIn: loggedIn,
      isNewUser: newUser,
      hasSeenIntro: prefs.getBool("seen_intro") ?? false,
      hasSeenProfileDetails:
      prefs.getBool("seen_profile_details") ?? false,
      hasSeenOnboarding: prefs.getBool("seen_onboarding") ?? false,
      hasSelectedLocation:
      prefs.getBool("selected_location") ?? false,
      latitude: prefs.getDouble("user_lat"),
      longitude: prefs.getDouble("user_lng"),
    );

    debugPrint(
      "✅ [APP STATE] load → "
          "token=${token != null}, "
          "loggedIn=$loggedIn, "
          "newUser=$newUser, "
          "location=${state.hasSelectedLocation}",
    );

    final savedAddress = prefs.getString("user_address");

    if (state.hasSelectedLocation &&
        state.latitude != null &&
        state.longitude != null) {

      ref.read(addressProvider.notifier).hydrateFromAppState(
        lat: state.latitude!,
        lng: state.longitude!,
        address: savedAddress ?? "Lütfen Konum Seçiniz",
      );
    }

  }

  // ------------------------------------------------------------------------
  // AUTH
  // ------------------------------------------------------------------------
  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", value);
    state = state.copyWith(isLoggedIn: value);
  }

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", token);
  }

  Future<void> setIsNewUser(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("is_new_user", value);
    state = state.copyWith(isNewUser: value);
    debugPrint("🚀 [APP STATE] isNewUser → $value");
  }

  // ------------------------------------------------------------------------
  // FLAGS
  // ------------------------------------------------------------------------
  Future<void> setHasSeenIntro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_intro", value);
    state = state.copyWith(hasSeenIntro: value);
  }

  Future<void> setHasSeenProfileDetails(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_profile_details", value);
    state = state.copyWith(hasSeenProfileDetails: value);
  }

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("seen_onboarding", value);
    state = state.copyWith(hasSeenOnboarding: value);
  }

  // ------------------------------------------------------------------------
  // ⭐ LOCATION (EN KRİTİK PARÇA)
  // ------------------------------------------------------------------------
  Future<void> setHasSelectedLocation(
      bool value, {
        double? lat,
        double? lng,
        String? address,
      }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("selected_location", value);

    if (lat != null && lng != null) {
      await prefs.setDouble("user_lat", lat);
      await prefs.setDouble("user_lng", lng);
    }

    if (address != null && address.isNotEmpty) {
      await prefs.setString("user_address", address);
    }

    state = state.copyWith(
      hasSelectedLocation: value,
      latitude: lat ?? state.latitude,
      longitude: lng ?? state.longitude,
    );

    debugPrint(
      "📍 [APP STATE] location selected → $value | $lat,$lng | $address",
    );
  }


  // ------------------------------------------------------------------------
  // LOGOUT (HARD RESET)
  // ------------------------------------------------------------------------
  Future<void> resetAfterLogout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    state = const AppState(
      isInitialized: true,
      isLoggedIn: false,
      isNewUser: false,
      hasSeenIntro: true,
    );

    debugPrint("🧹 [APP STATE] resetAfterLogout");
  }
}


// --------------------------------------------------------------------------
// PROVIDER
// --------------------------------------------------------------------------
final appStateProvider =
StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final locationRepo = ref.watch(locationRepositoryProvider);
  return AppStateNotifier(ref, locationRepo);
});


// --------------------------------------------------------------------------
// ROUTER REFRESH LISTENER
// --------------------------------------------------------------------------
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(appStateProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref ref;
}
