import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../location/domain/address_state.dart';
import '../../../stores/data/model/store_summary.dart';

class StoreMarkerLayer extends StatefulWidget {
  final AddressState address;
  final List<StoreSummary> stores;
  final void Function(StoreSummary store) onStoreSelected;
  final VoidCallback onMapTap;

  const StoreMarkerLayer({
    super.key,
    required this.address,
    required this.stores,
    required this.onStoreSelected,
    required this.onMapTap,
  });

  @override
  State<StoreMarkerLayer> createState() => _StoreMarkerLayerState();
}

class _StoreMarkerLayerState extends State<StoreMarkerLayer> {
  MapboxMap? _map;
  CircleAnnotationManager? _manager;

  final Map<String, StoreSummary> _storeById = {};

  // ------------------------------------------------
  // MAP CREATED
  // ------------------------------------------------
  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;

    _manager = await _map!.annotations.createCircleAnnotationManager();

    _manager!.addOnCircleAnnotationClickListener(
      _StoreClickListener(
        storeMap: _storeById,
        onStoreSelected: widget.onStoreSelected,
      ),
    );

    await _moveCamera();
  }


  // ------------------------------------------------
  // CAMERA
  // ------------------------------------------------
  Future<void> _moveCamera() async {
    await _map!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            widget.address.lng,
            widget.address.lat,
          ),
        ),
        zoom: 14.5,
      ),
    );
  }

  // ------------------------------------------------
  // ADDRESS (USER SELECTED)
  // ------------------------------------------------
  Future<void> _drawAddressCircle() async {
    if (_manager == null) return;

    await _manager!.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            widget.address.lng,
            widget.address.lat,
          ),
        ),
        circleRadius: 10,
        circleColor: const Color(0xFF2E7D32).value, // koyu yeşil
        circleStrokeColor: Colors.white.value,
        circleStrokeWidth: 3,
      ),
    );
  }

  // ------------------------------------------------
  // STORES
  // ------------------------------------------------
  Future<void> _drawStores() async {
    if (_manager == null) return;

    _storeById.clear();
    await _manager!.deleteAll();

    // adres marker tekrar
    await _drawAddressCircle();

    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final pos = Position(store.longitude!, store.latitude!);

      // 1️⃣ GİZLİ – BÜYÜK HITBOX
      final hit = await _manager!.create(
        CircleAnnotationOptions(
          geometry: Point(coordinates: pos),
          circleRadius: 22,
          circleColor: Colors.transparent.value,
        ),
      );

      // 2️⃣ GÖRÜNÜR – MAVİ NOKTA
      final visible = await _manager!.create(
        CircleAnnotationOptions(
          geometry: Point(coordinates: pos),
          circleRadius: 8,
          circleColor: const Color(0xFF1E88E5).value,
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2,
        ),
      );

      // 🔥 İKİ ID DE AYNI STORE’A BAĞLANIYOR
      _storeById[hit.id] = store;
      _storeById[visible.id] = store;
    }

  }


  // ------------------------------------------------
  // UPDATE
  // ------------------------------------------------
  @override
  void didUpdateWidget(covariant StoreMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final addressChanged =
        oldWidget.address.lat != widget.address.lat ||
            oldWidget.address.lng != widget.address.lng;

    final storesChanged =
        oldWidget.stores.length != widget.stores.length;

    if (_map != null && (addressChanged || storesChanged)) {
      _moveCamera();
      _drawStores();
    }
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: MapWidget(
        styleUri: MapboxStyles.MAPBOX_STREETS,
        onMapCreated: _onMapCreated,

        // 🔥 BURASI HAYAT KURTARIR
        onStyleLoadedListener: (_) async {
          debugPrint('🗺️ MAP STYLE LOADED');

          await _drawAddressCircle();
          await _drawStores();
        },

        onTapListener: (_) => widget.onMapTap(),
      ),
    );
  }

}

// ------------------------------------------------
// CLICK LISTENER
// ------------------------------------------------
class _StoreClickListener implements OnCircleAnnotationClickListener {
  final Map<String, StoreSummary> storeMap;
  final void Function(StoreSummary store) onStoreSelected;

  _StoreClickListener({
    required this.storeMap,
    required this.onStoreSelected,
  });

  @override
  bool onCircleAnnotationClick(CircleAnnotation annotation) {
    debugPrint('🟢 CIRCLE CLICK: ${annotation.id}');

    final store = storeMap[annotation.id];
    if (store != null) {
      debugPrint('✅ STORE: ${store.name}');
      onStoreSelected(store);
      return true;
    }

    debugPrint('❌ STORE NOT FOUND');
    return false;
  }
}
