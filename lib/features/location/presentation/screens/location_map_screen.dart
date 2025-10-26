import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/custom_button.dart';

class LocationMapScreen extends ConsumerStatefulWidget {
  const LocationMapScreen({super.key});

  @override
  ConsumerState<LocationMapScreen> createState() => _LocationMapScreenState();
}

class _LocationMapScreenState extends ConsumerState<LocationMapScreen> {
  late GoogleMapController mapController;
  LatLng _selectedPosition = const LatLng(41.0082, 28.9784); // İstanbul varsayılan
  bool showMap = true;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  void _onMapTapped(LatLng position) {
    setState(() => _selectedPosition = position);
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      debugPrint('Konum izni verildi');
    } else if (status.isDenied) {
      debugPrint('Kullanıcı reddetti');
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Konum izni gerekiyor. Lütfen ayarlardan izin verin.'),
          ),
        );
      }
    }
  }

  Future<void> _confirmLocation() async {
    // ✅ Konum seçildiyse states güncelle
    ref.read(appStateProvider.notifier).setLocationAccess(true);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🗺️ Şimdilik dummy map placeholder
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Text("Harita geçici olarak devre dışı"),
          ),

          // 📍 Alt Bilgi ve Butonlar
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Lat: ${_selectedPosition.latitude.toStringAsFixed(4)}, '
                              'Lng: ${_selectedPosition.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Adresim doğru',
                  onPressed: _confirmLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
