
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart'; // CustomButton import edildi
import '../../domain/address_notifier.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends ConsumerState<LocationPickerScreen> {
  MapboxMap? _map;
  Timer? _debounce;
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _map = mapboxMap;
  }

  void _onCameraChanged(CameraChangedEventData event) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      if (_map == null || !mounted) return;

      final cameraBounds = await _map!.getBounds();

      final swPoint = cameraBounds.bounds.southwest;
      final nePoint = cameraBounds.bounds.northeast;

      ref.read(addressProvider.notifier).updateVisibleRegion(
        swPoint.coordinates.lat.toDouble(),
        swPoint.coordinates.lng.toDouble(),
        nePoint.coordinates.lat.toDouble(),
        nePoint.coordinates.lng.toDouble(),
      );

      final cam = await _map!.getCameraState();
      final center = cam.center.coordinates;
      ref.read(addressProvider.notifier).setFromMap(
        lat: center.lat.toDouble(),
        lng: center.lng.toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Konum Seç',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
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
                  coordinates: Position(address.lng, address.lat),
                ),
                zoom: 15,
              ),
              onMapCreated: _onMapCreated,
              onCameraChangeListener: _onCameraChanged,
            ),
          ),

          /// 📍 SABİT PIN
          const Center(
            child: Icon(
              Icons.location_pin,
              size: 54,
              color: AppColors.primaryDarkGreen,
            ),
          ),

          /// 🔻 ALT PANEL (eski tasarıma çok yakın)
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
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primaryDarkGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
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

                // 👇 SADECE BURAYI DEĞİŞTİRDİM: ElevatedButton yerine CustomButton
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
                          .confirmLocation();

                      if (!mounted) return;

                      setState(() => _loading = false);

                      if (ok) {
                        context.go('/home'); // 🔥 NET
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
