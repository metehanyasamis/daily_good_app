import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final bool isFirstLaunch;
  final bool isLoggedIn;
  final bool hasCompletedProfile;
  final bool hasSeenOnboarding;
  final bool hasLocationAccess;

  // 🔥 Yeni Eklenenler
  final double? userLat;
  final double? userLng;
  final bool hasSelectedLocation;

  final String? name;
  final String? surname;
  final String? email;
  final String? gender;

  const AppState({
    this.isFirstLaunch = true,
    this.isLoggedIn = false,
    this.hasCompletedProfile = false,
    this.hasSeenOnboarding = false,
    this.hasLocationAccess = false,
    this.userLat,
    this.userLng,
    this.hasSelectedLocation = false,
    this.name,
    this.surname,
    this.email,
    this.gender,
  });

  AppState copyWith({
    bool? isFirstLaunch,
    bool? isLoggedIn,
    bool? hasCompletedProfile,
    bool? hasSeenOnboarding,
    bool? hasLocationAccess,
    double? userLat,
    double? userLng,
    bool? hasSelectedLocation,
    String? name,
    String? surname,
    String? email,
    String? gender,
  }) {
    return AppState(
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      hasCompletedProfile: hasCompletedProfile ?? this.hasCompletedProfile,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      hasLocationAccess: hasLocationAccess ?? this.hasLocationAccess,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      hasSelectedLocation: hasSelectedLocation ?? this.hasSelectedLocation,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      gender: gender ?? this.gender,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();

    state = AppState(
      isFirstLaunch: prefs.getBool('isFirstLaunch') ?? true,
      isLoggedIn: prefs.getBool('isLoggedIn') ?? false,
      hasCompletedProfile: prefs.getBool('hasCompletedProfile') ?? false,
      hasSeenOnboarding: prefs.getBool('hasSeenOnboarding') ?? false,
      hasLocationAccess: prefs.getBool('hasLocationAccess') ?? false,
      userLat: prefs.getDouble('userLat'),
      userLng: prefs.getDouble('userLng'),
      hasSelectedLocation: prefs.getBool('hasSelectedLocation') ?? false,
      name: prefs.getString('name'),
      surname: prefs.getString('surname'),
      email: prefs.getString('email'),
      gender: prefs.getString('gender'),
    );
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isFirstLaunch', state.isFirstLaunch);
    await prefs.setBool('isLoggedIn', state.isLoggedIn);
    await prefs.setBool('hasCompletedProfile', state.hasCompletedProfile);
    await prefs.setBool('hasSeenOnboarding', state.hasSeenOnboarding);
    await prefs.setBool('hasLocationAccess', state.hasLocationAccess);

    // 🔥 Yeni eklenenler kayıt ediliyor
    if (state.userLat != null) await prefs.setDouble('userLat', state.userLat!);
    if (state.userLng != null) await prefs.setDouble('userLng', state.userLng!);
    await prefs.setBool('hasSelectedLocation', state.hasSelectedLocation);

    await prefs.setString('name', state.name ?? '');
    await prefs.setString('surname', state.surname ?? '');
    await prefs.setString('email', state.email ?? '');
    await prefs.setString('gender', state.gender ?? '');
  }

  void setLocationAccess(bool value) {
    state = state.copyWith(hasLocationAccess: value);
    _saveState();
  }

  // 🔥 Kullanıcının seçtiği harita konumu kaydedilir
  void setUserLocation(double lat, double lng) {
    state = state.copyWith(
      userLat: lat,
      userLng: lng,
      hasSelectedLocation: true,
    );
    _saveState();
  }

  void setFirstLaunch(bool value) {
    state = state.copyWith(isFirstLaunch: value);
    _saveState();
  }

  void setLoggedIn(bool value) {
    state = state.copyWith(isLoggedIn: value);
    _saveState();
  }

  void setCompletedProfile(bool value) {
    state = state.copyWith(hasCompletedProfile: value);
    _saveState();
  }

  void setSeenOnboarding(bool value) {
    state = state.copyWith(hasSeenOnboarding: value);
    _saveState();
  }

  void setProfileCompleted(bool value) {
    setCompletedProfile(value); // alttaki fonksiyonu çağırıyor
  }
  void setOnboardingSeen(bool value) {
    setSeenOnboarding(value); // alttaki fonksiyonu çağırıyor
  }

  void setLocationSelected(bool value) {
    state = state.copyWith(hasSelectedLocation: value);
    _saveState();
  }

  void setSelectedLocation(bool value) {
    state = state.copyWith(hasSelectedLocation: value);
    _saveState();
  }

  void logout() {
    state = state.copyWith(isLoggedIn: false);
    _saveState();
  }

  void setProfile({
    String? name,
    String? surname,
    String? email,
    String? gender,
  }) {
    state = state.copyWith(
      name: name,
      surname: surname,
      email: email,
      gender: gender,
      hasCompletedProfile: true,
    );
    _saveState();
  }
}

final appStateProvider =
StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
