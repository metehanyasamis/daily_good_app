
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/address_notifier.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  MapboxMap? _map;
  Timer? _debounce;
  bool _loading = false;

  // Haritada gezindikçe güncellenen yerel state
  double? _tempLat;
  double? _tempLng;
  String _tempTitle = "Konum yükleniyor...";

  @override
  void initState() {
    super.initState();
    // 1. Mevcut (eski) konumu yükle
    final currentAddress = ref.read(addressProvider);
    _tempLat = currentAddress.lat;
    _tempLng = currentAddress.lng;
    _tempTitle = currentAddress.title;

    // 2. Açılışta otomatik canlı konum kontrolü (İzni darlamadan)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleLocationRequest(askPermission: false);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// 🎯 Hem açılışta hem de GPS butonuna basıldığında çalışan ana fonksiyon
  Future<void> _handleLocationRequest({required bool askPermission}) async {
    try {
      geo.LocationPermission permission = await geo.Geolocator.checkPermission();

      // Eğer butona basıldıysa ve izin yoksa iste
      if (askPermission && permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }

      if (permission == geo.LocationPermission.whileInUse ||
          permission == geo.LocationPermission.always) {

        setState(() => _loading = true);

        geo.Position position = await geo.Geolocator.getCurrentPosition();

        if (!mounted) return;

        // Haritayı canlı konuma uçur
        _map?.flyTo(
          CameraOptions(
            center: Point(
              coordinates: Position(position.longitude, position.latitude),
            ),
            zoom: 15.0,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    } catch (e) {
      debugPrint("📍 Konum Hatası: $e");
      if (askPermission && mounted) {
        Toasts.error(context, "Cihaz konumu alınamadı.");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _map = mapboxMap;
    // UI Süslemelerini kaldır
    _map?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    _map?.logo.updateSettings(LogoSettings(enabled: false));
    _map?.attribution.updateSettings(AttributionSettings(enabled: false));
  }

  void _onCameraChanged(CameraChangedEventData event) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (_map == null || !mounted) return;

      final cam = await _map!.getCameraState();
      final center = cam.center.coordinates;

      final double newLat = center.lat.toDouble();
      final double newLng = center.lng.toDouble();

      setState(() {
        _tempLat = newLat;
        _tempLng = newLng;
        _loading = true;
      });

      try {
        // Reverse Geocoding: Koordinattan adres metni bulma
        final String fullAddress = await ref.read(addressProvider.notifier).getAddressFromCoords(
          lat: newLat,
          lng: newLng,
        );

        if (!mounted) return;

        setState(() {
          _tempTitle = fullAddress;
          _loading = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _tempTitle = "Adres belirlenemedi";
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sadece başlangıç merkezi için global address'i bir kez alıyoruz
    final initialAddress = ref.read(addressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Konum Seç',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Stack(
        children: [
          /// 🗺️ HARİTA
          Positioned.fill(
            child: MapWidget(
              styleUri: MapboxStyles.MAPBOX_STREETS,
              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(initialAddress.lng, initialAddress.lat),
                ),
                zoom: 15,
              ),
              onMapCreated: _onMapCreated,
              onCameraChangeListener: _onCameraChanged,
            ),
          ),

          /// 📍 GPS BUTONU (Mevcut Konuma Git)
          Positioned(
            right: 16,
            top: 16,
            child: FloatingActionButton.small(
              heroTag: "picker_gps_fab",
              backgroundColor: Colors.white,
              onPressed: () => _handleLocationRequest(askPermission: true),
              child: const Icon(Icons.my_location, color: AppColors.primaryDarkGreen),
            ),
          ),

          /// 📍 SABİT MERKEZ PIN
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35), // Pin ucunu merkeze hizalamak için
              child: Icon(
                Icons.location_pin,
                size: 54,
                color: AppColors.primaryDarkGreen,
              ),
            ),
          ),

          /// 🔻 ALT PANEL (Adres Gösterimi ve Onay)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tempTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_loading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: PlatformWidgets.loader(strokeWidth: 2, radius: 8),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Konumu Onayla',
                    onPressed: _loading
                        ? null
                        : () async {
                      setState(() => _loading = true);

                      final ok = await ref
                          .read(addressProvider.notifier)
                          .updateConfirmedLocation(
                        lat: _tempLat!,
                        lng: _tempLng!,
                        title: _tempTitle,
                      );

                      if (!context.mounted) return;

                      setState(() => _loading = false);

                      if (ok) {
                        Toasts.success(context, "Konum başarıyla güncellendi.");
                        context.go('/home');
                      } else {
                        Toasts.error(context, "Konum güncellenirken bir hata oluştu.");
                      }
                    },

                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}