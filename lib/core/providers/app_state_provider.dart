import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final bool isLoggedIn;
  final bool hasSeenOnboarding;
  final bool hasSelectedLocation;  // kullanıcı konum seçti mi?
  final double? latitude;          // seçilen konum
  final double? longitude;

  const AppState({
    this.isLoggedIn = false,
    this.hasSeenOnboarding = false,
    this.hasSelectedLocation = false,
    this.latitude,
    this.longitude,
  });

  AppState copyWith({
    bool? isLoggedIn,
    bool? hasSeenOnboarding,
    bool? hasSelectedLocation,
    double? latitude,
    double? longitude,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasSelectedLocation: hasSelectedLocation ?? this.hasSelectedLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(this.ref) : super(const AppState()) {
    load();
  }

  final Ref ref;

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
  /// LOGIN
  /// ---------------------------------------------------------
  Future<void> setLoggedIn(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", v);

    state = state.copyWith(isLoggedIn: v);
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
  /// LOCATION SELECTED
  /// ---------------------------------------------------------
  Future<void> setLocationSelected(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("selected_location", v);

    state = state.copyWith(hasSelectedLocation: v);
  }

  /// ---------------------------------------------------------
  /// 📍 Konumu kaydet (Map Screen → "Adresim Doğru")
  /// ---------------------------------------------------------
  Future<void> setUserLocation(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("user_lat", lat);
    await prefs.setDouble("user_lng", lng);
    await prefs.setBool("selected_location", true);

    state = state.copyWith(
      latitude: lat,
      longitude: lng,
      hasSelectedLocation: true,
    );
  }

  /// ---------------------------------------------------------
  /// Kullanıcı konum izni verdi mi? (info screen)
  /// ---------------------------------------------------------
  Future<void> setLocationAccess(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("selected_location", v);

    state = state.copyWith(
      hasSelectedLocation: v,
    );
  }
}

final appStateProvider =
StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier(ref);
});
