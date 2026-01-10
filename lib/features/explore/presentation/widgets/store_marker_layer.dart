import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../location/domain/address_state.dart';
import '../../../stores/data/model/store_summary.dart';

class StoreMarkerLayer extends StatefulWidget {
  final AddressState address;
  final List<StoreSummary> stores;
  final void Function(StoreSummary store) onStoreSelected;
  final VoidCallback onMapTap;
  final Function(MapboxMap map)? onMapReady;


  const StoreMarkerLayer({
    super.key,
    required this.address,
    required this.stores,
    required this.onStoreSelected,
    required this.onMapTap,
    this.onMapReady,

  });


  @override
  State<StoreMarkerLayer> createState() => _StoreMarkerLayerState();
}

class _StoreMarkerLayerState extends State<StoreMarkerLayer> {
  MapboxMap? _map;
  CircleAnnotationManager? _circleManager;

  // Mağaza verilerini ID ile eşleştirmek için tutuyoruz
  final Map<String, StoreSummary> _storeByCircleId = {};
  String? _selectedStoreId;

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;

    // 🎯 YENİ YÖNTEM: Ayarları Settings nesneleri üzerinden yapıyoruz
    // Ölçek çubuğu (Scale Bar) kapatma
    map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Pusula (Compass) kapatma
    map.compass.updateSettings(CompassSettings(enabled: false));

    // Bilgi butonu (Attribution) kapatma
    map.attribution.updateSettings(AttributionSettings(enabled: false));



    if (widget.onMapReady != null) {
      widget.onMapReady!(map);
    }
  }

  Future<void> _onStyleLoaded() async {
    if (_map == null) return;

    // Sadece CircleManager (Daireler için) yeterli, LogoManager'ı sildik.
    _circleManager = await _map!.annotations.createCircleAnnotationManager();

    _circleManager!.addOnCircleAnnotationClickListener(
      _StoreCircleClickListener(
        storeMap: _storeByCircleId,
        onStoreSelected: (store) async {
          setState(() => _selectedStoreId = store.id);
          await _moveCameraToStore(store);
          _drawMarkers(); // Seçili olanın boyutunu değiştirmek için tekrar çiz
          widget.onStoreSelected(store);
        },
      ),
    );

    // İlk açılışta kamera ayarı
    _map!.setCamera(CameraOptions(
      center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
      zoom: 14.0,
    ));

    _drawMarkers();
  }

  Future<void> _drawMarkers() async {
    if (_map == null || _circleManager == null) return;

    // Eski markerları temizle
    await _circleManager!.deleteAll();
    _storeByCircleId.clear();

    // 🔵 KULLANICI KONUMU
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        circleRadius: 10,
        circleColor: Colors.blue.value,
        circleStrokeWidth: 2,
        circleStrokeColor: Colors.white.value,
      ),
    );

    // 🟢 SADECE YEŞİL DÜKKAN PİNLERİ
    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final isSelected = store.id == _selectedStoreId;

      final circle = await _circleManager!.create(
        CircleAnnotationOptions(
          geometry: Point(coordinates: Position(store.longitude!, store.latitude!)),
          circleRadius: isSelected ? 12 : 9, // Seçili olan biraz daha büyük
          circleColor: isSelected ? Colors.green.shade900.value : Colors.green.value,
          circleStrokeWidth: 2,
          circleStrokeColor: Colors.white.value,
        ),
      );

      // Tıklanan dairenin hangi dükkan olduğunu bilmek için ID'yi sakla
      _storeByCircleId[circle.id] = store;
    }
  }

  // Kamera hareketi
  Future<void> _moveCameraToStore(StoreSummary store) async {
    await _map?.flyTo(
      CameraOptions(center: Point(coordinates: Position(store.longitude!, store.latitude!)), zoom: 16.0),
      MapAnimationOptions(duration: 600),
    );
  }

  @override
  void didUpdateWidget(covariant StoreMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Adres değişirse kamerayı güncelle
    if (widget.address.lat != oldWidget.address.lat || widget.address.lng != oldWidget.address.lng) {
      _map?.setCamera(CameraOptions(
        center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        zoom: 14.0,
      ));
    }

    // Mağazalar veya adres değişirse markerları yeniden çiz
    if (widget.stores != oldWidget.stores || widget.address != oldWidget.address) {
      _drawMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (_) => _onStyleLoaded(),
      onTapListener: (_) => widget.onMapTap(),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        zoom: 14.0,
      ),
    );
  }
}

// Tıklama Dinleyicisi
class _StoreCircleClickListener implements OnCircleAnnotationClickListener {
  final Map<String, StoreSummary> storeMap;
  final void Function(StoreSummary store) onStoreSelected;
  _StoreCircleClickListener({required this.storeMap, required this.onStoreSelected});

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
