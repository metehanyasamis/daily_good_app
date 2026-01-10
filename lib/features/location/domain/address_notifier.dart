import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/data/prefs_service.dart';
import '../../../core/providers/app_state_provider.dart';
import '../data/repository/location_repository.dart';
import 'address_state.dart';

final addressProvider =
StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  final repo = ref.read(locationRepositoryProvider);
  return AddressNotifier(ref, repo);
});

class AddressNotifier extends StateNotifier<AddressState> {
  final Ref ref;
  final LocationRepository _repo;

  AddressNotifier(this.ref, this._repo)
      : super(const AddressState()) {
    _restoreFromPrefs(); // 🔥 APP AÇILINCA
  }

  Future<void> _restoreFromPrefs() async {
    final saved = await PrefsService.readAddress();
    if (saved != null) {
      state = saved;
      debugPrint("📍 Address restored from prefs → ${saved.title}");
    }
  }

  /// 🧭 Onboarding / mevcut konum
  void setAddress({
    required double lat,
    required double lng,
    required String title,
  }) async {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: title,
      isSelected: true,
    );

    // 🔥 KALICI KAYIT
    await PrefsService.saveAddress(
      title: title,
      lat: lat,
      lng: lng,
    );
  }

  /// 🗺️ Mapbox sürükleme → reverse geocoding
  Future<void> setFromMap({
    required double lat,
    required double lng,
  }) async {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: 'Adres belirleniyor...',
      isSelected: true,
    );

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        final street = p.thoroughfare;          // Hacı Ahmet Bey Sk.
        final number = p.subThoroughfare;        // 12 (varsa)
        final subLocality = p.subLocality;       // Bahariye
        final locality = p.locality;             // Kadıköy

        String addressLine = '';

        if (street != null && street.isNotEmpty) {
          addressLine = street;

          if (number != null && number.isNotEmpty) {
            addressLine += ' No:$number';
          }
        }

        final cityLine = [
          if (subLocality?.isNotEmpty == true) subLocality,
          if (locality?.isNotEmpty == true) locality,
        ].join(', ');

        final fullAddress = [
          if (addressLine.isNotEmpty) addressLine,
          if (cityLine.isNotEmpty) cityLine,
        ].join(', ');

        state = state.copyWith(
          title: fullAddress.isNotEmpty ? fullAddress : 'Seçilen Konum',
        );
      }
    } catch (_) {
      state = state.copyWith(title: 'Seçilen Konum');
    }
  }


  /// ✅ HARİTA ONAYI → BACKEND
  Future<bool> confirmLocation() async {
    final ok = await _repo.updateCustomerLocation(
      latitude: state.lat,
      longitude: state.lng,
      address: state.title,
    );

    if (ok) {
      // 🔥 SADECE APP STATE GÜNCELLE
      await ref.read(appStateProvider.notifier).setHasSelectedLocation(
        true,
        lat: state.lat,
        lng: state.lng,
        address: state.title,
      );

      // 🔥 Address zaten state olarak güncel
      state = state.copyWith(isSelected: true);
    }

    return ok;
  }



  /// ✅ /me endpoint’inden gelen data
  void setFromBackend({
    required double lat,
    required double lng,
    required String address,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: address,
      isSelected: true,
    );
  }


  void hydrateFromAppState({
    required double lat,
    required double lng,
    required String address,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: address,
      isSelected: true,
    );

    debugPrint("♻️ [ADDRESS] hydrated from AppState → $address");
  }

  Future<String> getAddressFromCoords({
    required double lat,
    required double lng,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final street = p.thoroughfare;
        final number = p.subThoroughfare;
        final subLocality = p.subLocality;
        final locality = p.locality;

        String addressLine = '';
        if (street != null && street.isNotEmpty) {
          addressLine = street;
          if (number != null && number.isNotEmpty) {
            addressLine += ' No:$number';
          }
        }

        final cityLine = [
          if (subLocality?.isNotEmpty == true) subLocality,
          if (locality?.isNotEmpty == true) locality,
        ].join(', ');

        final fullAddress = [
          if (addressLine.isNotEmpty) addressLine,
          if (cityLine.isNotEmpty) cityLine,
        ].join(', ');

        return fullAddress.isNotEmpty ? fullAddress : 'Seçilen Konum';
      }
    } catch (e) {
      debugPrint("❌ Geocoding hatası: $e");
    }
    return 'Seçilen Konum';
  }

  /// 🎯 Onay butonuna basıldığında hem state'i günceller hem de backend'e gönderir
  Future<bool> updateConfirmedLocation({
    required double lat,
    required double lng,
    required String title,
  }) async {
    // 1. Önce state'i güncelle (UI'da hemen yansıması için)
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: title,
      isSelected: true,
    );

    // 2. Yerel diske (Prefs) kaydet
    await PrefsService.saveAddress(title: title, lat: lat, lng: lng);

    // 3. Backend'e gönder (Zaten confirmLocation metodu bunu yapıyordu, doğrudan onu da çağırabilirsin)
    return await confirmLocation();
  }

  // final LatLngBounds? visibleBounds;

// address_notifier.dart içine ekle:
  void updateVisibleRegion(double swLat, double swLng, double neLat, double neLng) {
    debugPrint("📍 Harita Alanı Güncellendi:");
    debugPrint("   Sol Alt: $swLat, $swLng");
    debugPrint("   Sağ Üst: $neLat, $neLng");

    // Burada istersen repository'deki getStoresInBounds metodunu çağırabilirsin.
    _repo.getStoresInBounds(
      swLat: swLat,
      swLng: swLng,
      neLat: neLat,
      neLng: neLng,
    );
  }

}
