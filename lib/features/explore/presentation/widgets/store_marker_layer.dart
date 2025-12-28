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
  CircleAnnotationManager? _circleManager;
  PointAnnotationManager? _logoManager;

  final Map<String, StoreSummary> _storeByCircleId = {};
  final Set<String> _loadedBrandLogos = {};
  String? _selectedStoreId;

  // 1. ADIM: Katmanları kur ve tıklama dinleyicisini yeşil dairelere bağla
  Future<void> _onStyleLoaded() async {
    if (_map == null) return;

    _circleManager = await _map!.annotations.createCircleAnnotationManager();
    _logoManager = await _map!.annotations.createPointAnnotationManager();

    _circleManager!.addOnCircleAnnotationClickListener(
      _StoreCircleClickListener(
        storeMap: _storeByCircleId,
        onStoreSelected: (store) {
          setState(() => _selectedStoreId = store.id);
          widget.onStoreSelected(store);
          _drawMarkers();
        },
      ),
    );

    _drawMarkers();
  }

  // 2. ADIM: Çizim - Daireler her zaman çizilir, logolar indikçe gelir
  Future<void> _drawMarkers() async {
    if (_map == null || _circleManager == null) return;

    await _circleManager!.deleteAll();
    await _logoManager?.deleteAll();
    _storeByCircleId.clear();

    // Mavi Konum Noktası
    await _circleManager!.create(CircleAnnotationOptions(
      geometry: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
      circleRadius: 10,
      circleColor: Colors.blue.value,
      circleStrokeWidth: 2,
      circleStrokeColor: Colors.white.value,
    ));

    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final isSelected = store.id == _selectedStoreId;
      final brandId = store.brand?.id;

      // Yeşil Daire (Tıklanabilir Alan)
      final circle = await _circleManager!.create(CircleAnnotationOptions(
        geometry: Point(coordinates: Position(store.longitude!, store.latitude!)),
        circleRadius: isSelected ? 12 : 9,
        circleColor: isSelected ? Colors.green.shade900.value : Colors.green.value,
        circleStrokeWidth: 2,
        circleStrokeColor: Colors.white.value,
      ));

      _storeByCircleId[circle.id] = store;

      // Eğer logo indiyse üzerine bas
      if (brandId != null && _loadedBrandLogos.contains(brandId)) {
        await _logoManager?.create(PointAnnotationOptions(
          geometry: Point(coordinates: Position(store.longitude!, store.latitude!)),
          iconImage: brandId,
          iconSize: isSelected ? 0.8 : 0.6,
        ));
      } else if (brandId != null) {
        // Logo inmemişse sıraya al
        _downloadLogo(brandId, store.brand!.logoUrl);
      }
    }
  }

  // 3. ADIM: İndirme ve Register - Donmayı önlemek için optimizasyon
  Future<void> _downloadLogo(String id, String url) async {
    if (url.isEmpty || url.contains('localhost') || _loadedBrandLogos.contains(id)) return;

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer 51|fXtTkmpiHAh4p0HYrnHMG17iZGnJu6nX3SFF2UZz63dadf7f',
      });

      if (response.statusCode == 200 && _map != null) {
        // Loglardaki 'invalid size' hatasını önlemek için 3.0 scale ile ekliyoruz
        await _map!.style.addStyleImage(
            id,
            3.0,
            MbxImage(width: 100, height: 100, data: response.bodyBytes),
            false, [], [], null
        );

        if (mounted) {
          _loadedBrandLogos.add(id);
          // 500 dükkan için optimizasyon: Her indirmede değil, müsait olunca çiz
          WidgetsBinding.instance.addPostFrameCallback((_) => _drawMarkers());
        }
      }
    } catch (e) {
      debugPrint("Logo hatası: $id - $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      styleUri: MapboxStyles.MAPBOX_STREETS,
      onMapCreated: (map) => _map = map,
      onStyleLoadedListener: (_) => _onStyleLoaded(),
      onTapListener: (_) => widget.onMapTap(),
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        zoom: 14.0,
      ),
    );
  }
}

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

///Github verisyonu gibi, mavi  ve yeşil pinler var
/*
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
  CircleAnnotationManager? _circleManager;
  PointAnnotationManager? _logoManager;

  final Map<String, StoreSummary> _storeByCircleId = {};
  final Set<String> _loadedBrandLogos = {};
  String? _selectedStoreId;

  Future<void> _onMapCreated(MapboxMap map) async {
    _map = map;
  }

  Future<void> _onStyleLoaded() async {
    if (_map == null) return;

    _circleManager = await _map!.annotations.createCircleAnnotationManager();
    _logoManager = await _map!.annotations.createPointAnnotationManager();

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

    // 🔴 1. DOKUNUŞ: Harita açıldığında (Restart sonrası) kamerayı hedefe kilitle
    _map!.setCamera(CameraOptions(
      center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
      zoom: 14.0,
    ));

    _drawMarkers();
  }

  Future<void> _drawMarkers() async {
    if (_map == null || _circleManager == null) return;

    await _circleManager!.deleteAll();
    await _logoManager?.deleteAll();
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

    // 🟢 DÜKKANLAR
    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final isSelected = store.id == _selectedStoreId;
      final brandId = store.brand?.id;

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

      if (brandId != null && _loadedBrandLogos.contains(brandId)) {
        await _logoManager?.create(
          PointAnnotationOptions(
            geometry: Point(coordinates: Position(store.longitude!, store.latitude!)),
            iconImage: brandId,
            iconSize: 0.6,
          ),
        );
      } else if (brandId != null) {
        _downloadAndRegisterImage(brandId, store.brand!.logoUrl);
      }
    }
  }

  Future<void> _downloadAndRegisterImage(String id, String url) async {
    if (url.isEmpty || url.contains('localhost')) return;
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer 51|fXtTkmpiHAh4p0HYrnHMG17iZGnJu6nX3SFF2UZz63dadf7f',
      });

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        if (_map == null) return;
        await _map!.style.addStyleImage(id, 3.0, MbxImage(width: 100, height: 100, data: bytes), false, [], [], null);
        if (mounted) {
          _loadedBrandLogos.add(id);
          WidgetsBinding.instance.addPostFrameCallback((_) => _drawMarkers());
        }
      }
    } catch (e) {
      debugPrint("❌ Logo hatası: $e");
    }
  }

  Future<void> _moveCameraToStore(StoreSummary store) async {
    await _map?.flyTo(
      CameraOptions(center: Point(coordinates: Position(store.longitude!, store.latitude!)), zoom: 16.0),
      MapAnimationOptions(duration: 600),
    );
  }

  @override
  void didUpdateWidget(covariant StoreMarkerLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 🔴 2. DOKUNUŞ: Restart sonrası adres değişirse kamerayı oraya zorla uçur
    if (widget.address.lat != oldWidget.address.lat || widget.address.lng != oldWidget.address.lng) {
      _map?.setCamera(CameraOptions(
        center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        zoom: 14.0,
      ));
    }
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
      // 🔴 3. DOKUNUŞ: Harita henüz çizilirken Amerika'ya bakmasın
      cameraOptions: CameraOptions(
        center: Point(coordinates: Position(widget.address.lng, widget.address.lat)),
        zoom: 14.0,
      ),
    );
  }
}

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

 */



/*
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbx;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart'; // Mavi pin kontrolü için şart

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
  mbx.MapboxMap? _map;
  mbx.PointAnnotationManager? _logoManager;
  final Map<String, StoreSummary> _storeByAnnotationId = {};
  final Set<String> _loadedBrandLogos = {};
  String? _selectedStoreId;

  Future<void> _onMapCreated(mbx.MapboxMap map) async {
    _map = map;
    debugPrint("🔵 [MAP] onMapCreated bitti.");
  }

  Future<void> _onStyleLoaded() async {
    if (_map == null) return;
    debugPrint("🔵 [MAP] onStyleLoaded başladı.");

    // 1️⃣ MAVİ PİN AKTİVASYONU (Fix denemesi)
    try {
      final permission = await Geolocator.checkPermission();
      debugPrint("🔵 [MAP] Konum izni durumu: $permission");

      await _map!.location.updateSettings(mbx.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
        showAccuracyRing: true,
        locationPuck: mbx.LocationPuck(
          locationPuck2D: mbx.LocationPuck2D(),
        ),
      ));
      debugPrint("✅ [MAP] Mavi pin (Location Component) ayarları uygulandı.");
    } catch (e) {
      debugPrint("❌ [MAP] Mavi pin hatası: $e");
    }

    // 2️⃣ MANAGER KURULUMU
    _logoManager = await _map!.annotations.createPointAnnotationManager();
    _logoManager!.addOnPointAnnotationClickListener(
      _StorePointClickListener(
        storeMap: _storeByAnnotationId,
        onStoreSelected: (store) {
          setState(() => _selectedStoreId = store.id);
          _moveCameraToStore(store);
          _drawMarkers();
          widget.onStoreSelected(store);
        },
      ),
    );

    // 3️⃣ KAMERA VE ÇİZİM
    await _map!.setCamera(mbx.CameraOptions(
      center: mbx.Point(coordinates: mbx.Position(widget.address.lng, widget.address.lat)),
      zoom: 14.0,
    ));
    debugPrint("🔵 [MAP] Kamera odaklandı, markerlar çiziliyor...");

    _drawMarkers();
  }

  Future<void> _drawMarkers() async {
    if (_map == null || _logoManager == null) return;

    await _logoManager!.deleteAll();
    _storeByAnnotationId.clear();
    debugPrint("🔵 [MAP] ${widget.stores.length} mağaza için marker döngüsü başladı.");

    for (final store in widget.stores) {
      if (store.latitude == null || store.longitude == null) continue;

      final isSelected = store.id == _selectedStoreId;
      final brandId = isSelected ? "${store.brand?.id}_selected" : store.brand?.id;

      if (brandId != null && _loadedBrandLogos.contains(brandId)) {
        final annotation = await _logoManager!.create(
          mbx.PointAnnotationOptions(
            geometry: mbx.Point(coordinates: mbx.Position(store.longitude!, store.latitude!)),
            iconImage: brandId,
            iconSize: 0.8,
          ),
        );
        _storeByAnnotationId[annotation.id] = store;
      } else if (store.brand?.id != null) {
        _downloadAndProcessLogo(store.brand!.id, store.brand!.logoUrl, isSelected);
      }
    }
  }

  Future<void> _downloadAndProcessLogo(String id, String url, bool isSelected) async {
    final storageId = isSelected ? "${id}_selected" : id;
    if (_loadedBrandLogos.contains(storageId) || url.isEmpty || !url.startsWith('http')) return;

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer 51|fXtTkmpiHAh4p0HYrnHMG17iZGnJu6nX3SFF2UZz63dadf7f',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final ui.Codec codec = await ui.instantiateImageCodec(response.bodyBytes, targetWidth: 60, targetHeight: 60);
        final ui.FrameInfo fi = await codec.getNextFrame();

        final pictureRecorder = ui.PictureRecorder();
        final canvas = Canvas(pictureRecorder);
        const double canvasSize = 80.0;
        const double radius = 40.0;

        final paint = Paint()..isAntiAlias = true;
        paint.color = isSelected ? const Color(0xFF1B5E20) : const Color(0xFF4CAF50);
        canvas.drawCircle(const Offset(radius, radius), radius, paint);
        paint.color = Colors.white;
        canvas.drawCircle(const Offset(radius, radius), radius - 4, paint);

        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: const Offset(radius, radius), radius: radius - 6)));
        canvas.drawImageRect(fi.image, Rect.fromLTWH(0, 0, fi.image.width.toDouble(), fi.image.height.toDouble()),
            Rect.fromCircle(center: const Offset(radius, radius), radius: radius - 6), paint);
        canvas.restore();

        final finalImage = await pictureRecorder.endRecording().toImage(80, 80);
        final byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);

        if (byteData != null && _map != null) {
          await _map!.style.addStyleImage(storageId, 3.0,
              mbx.MbxImage(width: 80, height: 80, data: byteData.buffer.asUint8List()),
              false, [], [], null);

          _loadedBrandLogos.add(storageId);
          debugPrint("✅ [LOGO] Stil yüklendi: $storageId");
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _drawMarkers());
          }
        }
      }
    } catch (e) {
      debugPrint("❌ [LOGO_ERROR] $id için hata: $e");
    }
  }

  Future<void> _moveCameraToStore(StoreSummary store) async {
    await _map?.flyTo(mbx.CameraOptions(
        center: mbx.Point(coordinates: mbx.Position(store.longitude!, store.latitude!)),
        zoom: 16.0), mbx.MapAnimationOptions(duration: 600));
  }

  @override
  Widget build(BuildContext context) {
    return mbx.MapWidget(
      styleUri: mbx.MapboxStyles.MAPBOX_STREETS,
      onMapCreated: _onMapCreated,
      onStyleLoadedListener: (_) => _onStyleLoaded(),
      onTapListener: (_) => widget.onMapTap(),
    );
  }
}

class _StorePointClickListener implements mbx.OnPointAnnotationClickListener {
  final Map<String, StoreSummary> storeMap;
  final void Function(StoreSummary store) onStoreSelected;
  _StorePointClickListener({required this.storeMap, required this.onStoreSelected});
  @override
  bool onPointAnnotationClick(mbx.PointAnnotation annotation) {
    if (storeMap.containsKey(annotation.id)) {
      onStoreSelected(storeMap[annotation.id]!);
      return true;
    }
    return false;
  }
}

*/