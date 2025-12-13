// lib/features/location/presentation/screens/location_info_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../domain/address_notifier.dart';

class LocationInfoScreen extends ConsumerWidget {
  const LocationInfoScreen({super.key});

  Future<void> _requestLocation(BuildContext context, WidgetRef ref) async {
    // 1️⃣ Location service açık mı?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konum servisi kapalı")),
      );
      return;
    }

    // 2️⃣ Permission kontrol
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konum izni reddedildi")),
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Konum izni ayarlardan açılmalı"),
        ),
      );
      return;
    }

    // 3️⃣ Konumu al
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 4️⃣ State’e yaz
    ref.read(addressProvider.notifier).setAddress(
      lat: position.latitude,
      lng: position.longitude,
      title: 'Mevcut Konum',
    );

    // 5️⃣ Map picker’a git (onay için)
    context.push('/location-picker');
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Sana uygun sürpriz paketleri keşfetmek için konumunu seç.',
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
                context.push('/location-picker');
              },
              child: const Text('Haritadan seçeceğim'),
            ),
          ],
        ),
      ),
    );
  }
}
