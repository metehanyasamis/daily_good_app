import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _kHasSeenProfileDetails = 'has_seen_profile_details';
  static const _kHasSeenOnboarding = 'has_seen_onboarding';
  static const _kAuthToken = 'auth_token';
  static const _kUserData = 'user_data';

  static Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // 🔹 Token işlemleri
  static Future<void> saveToken(String token) async {
    final p = await _prefs;
    await p.setString(_kAuthToken, token);
  }

  static Future<String?> readToken() async {
    final p = await _prefs;
    return p.getString(_kAuthToken);
  }

  static Future<void> clearToken() async {
    final p = await _prefs;
    await p.remove(_kAuthToken);
  }

  static Future<void> clearAll() async {
    final p = await _prefs;
    await p.clear();
  }

  // 🔹 Profil flag
  static Future<void> setHasSeenProfileDetails(bool v) async {
    final p = await _prefs;
    await p.setBool(_kHasSeenProfileDetails, v);
  }

  static Future<bool> getHasSeenProfileDetails() async {
    final p = await _prefs;
    return p.getBool(_kHasSeenProfileDetails) ?? false;
  }

  // 🔹 Onboarding flag
  static Future<void> setHasSeenOnboarding(bool v) async {
    final p = await _prefs;
    await p.setBool(_kHasSeenOnboarding, v);
  }

  static Future<bool> getHasSeenOnboarding() async {
    final p = await _prefs;
    return p.getBool(_kHasSeenOnboarding) ?? false;
  }

  static Future<void> saveUserData(Map<String, dynamic> userMap) async {
    final p = await _prefs;
    await p.setString(_kUserData, jsonEncode(userMap));
  }

  static Future<Map<String, dynamic>?> readUserData() async {
    final p = await _prefs;
    final jsonStr = p.getString(_kUserData);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  static Future<void> clearUserData() async {
    final p = await _prefs;
    await p.remove(_kUserData);
  }

}
