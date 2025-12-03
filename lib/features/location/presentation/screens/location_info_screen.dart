// lib/features/location/presentation/screens/location_info_screen.dart

// ... (import'lar aynı kaldı) ...

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/custom_button.dart';

class LocationInfoScreen extends ConsumerWidget {
  const LocationInfoScreen({super.key});

  Future<void> _requestLocation(BuildContext context, WidgetRef ref) async {
    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      final position = await Geolocator.getCurrentPosition();
      debugPrint("Konum: ${position.latitude}, ${position.longitude}");

      // ✅ Konumu API'ye ve Lokal State'e kaydet (AppStateNotifier'a taşıdık)
      // Geocoding işlemi (Lat/Lng'den adres bulma) burada yapılabilir, 
      // şimdilik varsayılan adres gönderiyoruz.
      ref.read(appStateProvider.notifier).setUserLocation(
        position.latitude,
        position.longitude,
        address: "Mevcut Cihaz Konumu (API)",
      );

      // ✅ Konum başarıyla ayarlandı, anasayfaya (veya Explore) yönlendir
      context.go('/home'); // Varsayılan home rotasına yönlendiriyoruz
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konum izni gerekli")),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        // ... (UI kodları aynı kaldı) ...
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Sana uygun sürpriz paketleri keşfetmek için haritada yerini seç, sana yakın olan yerleri listele.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Mevcut Konumumu Kullan',
              onPressed: () => _requestLocation(context, ref),
              showPrice: false,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Kullanıcı manuel seçim yapmak istiyor, Placeholder/Harita ekranına git
                // Mapbox bağlantısı yapılana kadar bu, manuel giriş/seçim ekranı olacak.
                context.go('/location-picker'); // Rotayı LocationPickerScreen'a yönlendiriyoruz
              },
              child: const Text('Kendim gireceğim'),
            ),
          ],
        ),
      ),
    );
  }
}