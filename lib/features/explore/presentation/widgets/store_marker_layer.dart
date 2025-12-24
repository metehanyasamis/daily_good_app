import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;

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
  CircleAnnotationManager? _circleManager; // 🔵 KESİN ÇÖZÜM: İkon yerine Daire kullanıyoruz
  PointAnnotationManager? _logoManager;   // 🖼️ Logolar inerse üstüne basmak için

  final Map<String, StoreSummary> _storeByCircleId = {};
  final Set<String> _loadedBrandLogos = {};
  String? _selectedStoreId;

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
  }

  Future<void> _onStyleLoaded() async {
    if (_map == null) return;

    // Hem daire hem de (ilerisi için) nokta yöneticilerini oluştur
    _circleManager = await _map!.annotations.createCircleAnnotationManager();
    _logoManager = await _map!.annotations.createPointAnnotationManager();

    // Daire tıklama dinleyicisi
    _circleManager!.addOnCircleAnnotationClickListener(
      _StoreCircleClickListener(
        storeMap: _storeByCircleId,
        onStoreSelected: (store) async {
          setState(() => _selectedStoreId = store.id);
          await _moveCameraToStore(store);
          _drawMarkers();
          widget.onStoreSelected(store);
        },
      ),
    );

    // Başlangıç kamerası
    await _map!.setCamera(CameraOptions(
      center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
      zoom: 14.0,
    ));

    _drawMarkers();
  }

  /// ✅ TAM REFACTOR: Görünmeme ihtimalini ortadan kaldıran çizim fonksiyonu
  Future<void> _drawMarkers() async {
    if (_map == null || _circleManager == null) return;

    await _circleManager!.deleteAll();
    await _logoManager?.deleteAll();
    _storeByCircleId.clear();

    // 1️⃣ KULLANICI KONUMU (Kesin görünen Mavi Daire)
    await _circleManager!.create(
      CircleAnnotationOptions(
        geometry: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        circleRadius: 10,
        circleColor: Colors.blue.value,
        circleStrokeWidth: 2,
        circleStrokeColor: Colors.white.value,
      ),
    );

    // 2️⃣ DÜKKANLAR (Kesin görünen Yeşil Daireler)
    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final isSelected = store.id == _selectedStoreId;
      final brandId = store.brand?.id;

      // Daireyi çiz (Bu her zaman görünür)
      final circle = await _circleManager!.create(
        CircleAnnotationOptions(
          geometry: Point(coordinates: Position(store.longitude!, store.latitude!)),
          circleRadius: isSelected ? 12 : 9,
          circleColor: isSelected ? Colors.green.shade900.value : Colors.green.value,
          circleStrokeWidth: 2,
          circleStrokeColor: Colors.white.value,
        ),
      );

      _storeByCircleId[circle.id] = store;

      // 3️⃣ LOGO (Eğer daha önce indiyse dairenin üstüne bas)
      if (brandId != null && _loadedBrandLogos.contains(brandId)) {
        await _logoManager?.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(store.longitude!, store.latitude!)),
            iconImage: brandId,
            iconSize: 0.6,
          ),
        );
      } else if (brandId != null) {
        // Logo inmemişse indirmeyi başlat
        _downloadAndRegisterImage(brandId, store.brand!.logoUrl);
      }
    }
  }

// lib/features/explore/presentation/widgets/store_marker_layer.dart

  Future<void> _downloadAndRegisterImage(String id, String url) async {
    if (url.isEmpty || url.contains('localhost')) return;

    try {
      // 🔑 TOKEN EKLEME: Sunucu 403 veriyorsa muhtemelen bu header'ı bekliyordur
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer 51|fXtTkmpiHAh4p0HYrnHMG17iZGnJu6nX3SFF2UZz63dadf7f', // Loglarındaki aktif token
          'Accept': 'image/*',
        },
      );

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;

        if (_map == null) return;

        await _map!.style.addStyleImage(
          id,
          3.0,
          MbxImage(width: 100, height: 100, data: bytes),
          false,
          [], [], null,
        );

        debugPrint("✅ [MAP_DEBUG] Logo BAŞARIYLA eklendi: $id");

        if (mounted) {
          _loadedBrandLogos.add(id);
          WidgetsBinding.instance.addPostFrameCallback((_) => _drawMarkers());
        }
      } else {
        // Hala 403 geliyorsa konsola yazdırıyoruz
        debugPrint("⚠️ [MAP_DEBUG] Logo hala çekilemiyor. Kod: ${response.statusCode} URL: $url");
      }
    } catch (e) {
      debugPrint("❌ [MAP_DEBUG] Logo indirme sırasında hata: $e");
    }
  }

  Future<void> _moveCameraToStore(StoreSummary store) async {
    await _map?.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(store.longitude!, store.latitude!)),
        zoom: 16.0,
      ),
      MapAnimationOptions(duration: 600),
    );
  }

  @override
  void didUpdateWidget(covariant StoreMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stores != oldWidget.stores) _drawMarkers();
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

/// Daireler için özel Click Listener
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