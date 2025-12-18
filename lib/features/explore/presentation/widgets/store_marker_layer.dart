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
  String? _selectedStoreId;


  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
  }

  Future<void> _onStyleLoaded() async {
    if (_map == null) return;

    _manager = await _map!.annotations.createCircleAnnotationManager();

    _manager!.addOnCircleAnnotationClickListener(
      _StoreClickListener(
        storeMap: _storeById,
        onStoreSelected: (store) async {
          // 1️⃣ seçilen store id
          setState(() {
            _selectedStoreId = store.id;
          });

          // 2️⃣ kamera store’a gitsin
          await _moveCameraToStore(store);

          // 3️⃣ marker’ları yeniden çiz (renk değişsin)
          await _manager!.deleteAll();
          await _drawAddress();
          await _drawStores();

          // 4️⃣ üst widget’a bildir (mini card çıksın)
          widget.onStoreSelected(store);
        },
      ),
    );


    // 🎯 Kamera: sadece adres
    await _map!.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            widget.address.lng.toDouble(),
            widget.address.lat.toDouble(),
          ),
        ),
        zoom: 14.5,
      ),
    );

    await _drawAddress();
    await _drawStores();
  }

  Future<void> _drawAddress() async {
    await _manager!.create(
      CircleAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            widget.address.lng,
            widget.address.lat,
          ),
        ),
        circleRadius: 10,
        circleColor: Colors.blue.value, // 🔵 USER
        circleStrokeColor: Colors.white.value,
        circleStrokeWidth: 3,
      ),
    );
  }


  Future<void> _drawStores() async {
    _storeById.clear();

    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final isSelected = store.id == _selectedStoreId;

      final annotation = await _manager!.create(
        CircleAnnotationOptions(
          geometry: Point(
            coordinates: Position(
              store.longitude!,
              store.latitude!,
            ),
          ),
          circleRadius: isSelected ? 10 : 8,
          circleColor: isSelected
              ? Colors.green.shade800.value // 🟢 KOYU YEŞİL
              : Colors.green.value,         // 🟢 NORMAL
          circleStrokeColor: Colors.white.value,
          circleStrokeWidth: 2,
        ),
      );

      _storeById[annotation.id] = store;
    }
  }

  Future<void> _moveCameraToStore(StoreSummary store) async {
    if (_map == null) return;
    if (store.latitude == null || store.longitude == null) return;

    await _map!.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            store.longitude!,
            store.latitude!,
          ),
        ),
        zoom: 16.5,
      ),
      MapAnimationOptions(
        duration: 600,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (_) => _onStyleLoaded(),
      onTapListener: (_) => widget.onMapTap(),
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
    final store = storeMap[annotation.id];
    if (store != null) {
      onStoreSelected(store);
      return true;
    }
    return false;
  }
}

