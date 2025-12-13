import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/location/domain/address_state.dart';

class PrefsService {
  static const _kAuthToken = 'auth_token';
  static const _kUserData = 'user_data';
  static const _kHasSeenProfileDetails = 'has_seen_profile_details';
  static const _kHasSeenOnboarding = 'has_seen_onboarding';

  // 🔥 Bellekte token saklama — race condition önler
  static String? inMemoryToken;

  static Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  // -------------------------------------------------------------
  // 🔑 TOKEN — SAVE
  // -------------------------------------------------------------
  static Future<void> saveToken(String token) async {
    final p = await _prefs;
    await p.setString(_kAuthToken, token);
    inMemoryToken = token;

    print("💾 [Prefs] Token saved → $token");
  }

  // -------------------------------------------------------------
  // 🔑 TOKEN — READ
  // -------------------------------------------------------------
  static Future<String?> readToken() async {
    if (inMemoryToken != null && inMemoryToken!.isNotEmpty) {
      return inMemoryToken;
    }

    final p = await _prefs;
    final token = p.getString(_kAuthToken);

    if (token != null && token.isNotEmpty) {
      inMemoryToken = token;
    }

    print("📥 [Prefs] Token read → $token");
    return token;
  }

  // -------------------------------------------------------------
  // TOKEN — CLEAR
  // -------------------------------------------------------------
  static Future<void> clearToken() async {
    final p = await _prefs;
    await p.remove(_kAuthToken);
    inMemoryToken = null;
  }

  // -------------------------------------------------------------
  // CLEAR ALL (projede kullanılıyor!)
  // -------------------------------------------------------------
  static Future<void> clearAll() async {
    final p = await _prefs;
    await p.clear();
    inMemoryToken = null;
  }

  // -------------------------------------------------------------
  // USER DATA
  // -------------------------------------------------------------
  static Future<void> saveUserData(Map<String, dynamic> user) async {
    final p = await _prefs;
    await p.setString(_kUserData, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> readUserData() async {
    final p = await _prefs;
    final str = p.getString(_kUserData);
    if (str == null) return null;

    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserData() async {
    final p = await _prefs;
    await p.remove(_kUserData);
  }

  // -------------------------------------------------------------
  // FLAGS
  // -------------------------------------------------------------
  static Future<void> setHasSeenProfileDetails(bool v) async {
    final p = await _prefs;
    await p.setBool(_kHasSeenProfileDetails, v);
  }

  static Future<bool> getHasSeenProfileDetails() async {
    final p = await _prefs;
    return p.getBool(_kHasSeenProfileDetails) ?? false;
  }

  static Future<void> setHasSeenOnboarding(bool v) async {
    final p = await _prefs;
    await p.setBool(_kHasSeenOnboarding, v);
  }

  static Future<bool> getHasSeenOnboarding() async {
    final p = await _prefs;
    return p.getBool(_kHasSeenOnboarding) ?? false;
  }

  // -------------------------------------------------------------
  // GENERIC METHODS (projede kullanılan yerler için geri eklendi)
  // -------------------------------------------------------------
  static Future<void> setString(String key, String value) async {
    final p = await _prefs;
    await p.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final p = await _prefs;
    return p.getString(key);
  }

  static Future<void> remove(String key) async {
    final p = await _prefs;
    await p.remove(key);
  }

// -------------------------------------------------------------
// 📍 ADDRESS
// -------------------------------------------------------------
  static const _kAddressTitle = 'address_title';
  static const _kAddressLat = 'address_lat';
  static const _kAddressLng = 'address_lng';
  static const _kAddressSelected = 'address_selected';

  static Future<void> saveAddress({
    required String title,
    required double lat,
    required double lng,
  }) async {
    final p = await _prefs;
    await p.setString(_kAddressTitle, title);
    await p.setDouble(_kAddressLat, lat);
    await p.setDouble(_kAddressLng, lng);
    await p.setBool(_kAddressSelected, true);

    print("💾 [Prefs] Address saved → $title ($lat, $lng)");
  }

  static Future<AddressState?> readAddress() async {
    final p = await _prefs;

    final title = p.getString(_kAddressTitle);
    final lat = p.getDouble(_kAddressLat);
    final lng = p.getDouble(_kAddressLng);
    final selected = p.getBool(_kAddressSelected) ?? false;

    if (title == null || lat == null || lng == null) return null;

    return AddressState(
      title: title,
      lat: lat,
      lng: lng,
      isSelected: selected,
    );
  }


}
