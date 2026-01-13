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

// Satır 64 civarı:
    _circleManager = await _map!.annotations.createCircleAnnotationManager();

    // ✅ Mapbox 2.17.0+ için doğru metod yolu budur:
    _circleManager!.tapEvents(onTap: (annotation) {
      final store = _storeByCircleId[annotation.id];
      if (store != null) {
        setState(() => _selectedStoreId = store.id);
        _moveCameraToStore(store);
        _drawMarkers();
        widget.onStoreSelected(store);
        return true;
      }
      return false;
    });

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
        circleColor: Colors.blue.toARGB32(),
        circleStrokeWidth: 2,
        circleStrokeColor: Colors.white.toARGB32(),
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
          circleColor: isSelected ? Colors.green.shade900.toARGB32() : Colors.green.toARGB32(),
          circleStrokeWidth: 2,
          circleStrokeColor: Colors.white.toARGB32(),
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

