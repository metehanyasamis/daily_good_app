import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'address_state.dart';

final addressProvider =
StateNotifierProvider<AddressNotifier, AddressState>(
      (ref) => AddressNotifier(),
);

class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier() : super(const AddressState());

  /// Onboarding / manuel seçim
  void setAddress({
    required double lat,
    required double lng,
    required String title,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: title,
      isSelected: true,
    );
  }

  /// 🗺️ Mapbox üzerinden seçilen konum
  void setFromMap({
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(
      lat: lat,
      lng: lng,
      title: 'Seçilen Konum',
      isSelected: true,
    );
  }

  void clear() {
    state = const AddressState();
  }
}
