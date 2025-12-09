import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/providers/app_state_provider.dart';

class LocationMapScreen extends ConsumerStatefulWidget {
  const LocationMapScreen({super.key});

  @override
  ConsumerState<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends ConsumerState<LocationMapScreen> {
  GoogleMapController? _mapController;

  LatLng? _selectedPosition;
  LatLng _initialCenter = const LatLng(40.9929, 29.0270); // default Kadikoy
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _prepareInitialLocation();
  }

  /// ---------------------------------------------------------------
  /// 📍 1) Kullanıcının mevcut konumunu al (izin varsa)
  /// ---------------------------------------------------------------
  Future<void> _prepareInitialLocation() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        final pos = await Geolocator.getCurrentPosition();
        _initialCenter = LatLng(pos.latitude, pos.longitude);
        _selectedPosition = _initialCenter;
      } else {
        // izin yok: default konum ile aç
        _selectedPosition = _initialCenter;
      }
    } catch (_) {
      _selectedPosition = _initialCenter;
    }

    setState(() => _isLoading = false);
  }

  /// ---------------------------------------------------------------
  /// 📍 2) Haritaya tıklayınca marker güncelle
  /// ---------------------------------------------------------------
  void _onMapTapped(LatLng position) {
    setState(() => _selectedPosition = position);
  }

  /// ---------------------------------------------------------------
  /// 📍 3) "Adresim doğru" → Home'a LatLng gönder
  /// ---------------------------------------------------------------
  void _confirmLocation() async {
    if (_selectedPosition != null) {

      await ref.read(appStateProvider.notifier).setUserLocation(
        _selectedPosition!.latitude,
        _selectedPosition!.longitude,
      );

      // ❌ Bunu siliyoruz:
      // ref.read(appRouterProvider).go('/home');

      // ✔ Router state değişince kendi yönlendirecek.
    }
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          /// 🌍 Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCenter,
              zoom: 15,
            ),
            onTap: _onMapTapped,
            onMapCreated: (controller) => _mapController = controller,
            markers: _selectedPosition == null
                ? {}
                : {
              Marker(
                markerId: const MarkerId("selected"),
                position: _selectedPosition!,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          /// 🔘 Alt panel + buton
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Seçilen nokta bilgisi
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Lat: ${_selectedPosition!.latitude.toStringAsFixed(4)}, "
                              "Lng: ${_selectedPosition!.longitude.toStringAsFixed(4)}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: _confirmLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Adresim doğru",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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
