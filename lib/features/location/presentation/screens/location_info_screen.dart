// lib/features/location/presentation/screens/location_info_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/platform/toasts.dart'; // 🚀 Yeni eklendi
import '../../../../core/platform/dialogs.dart'; // 🚀 Yeni eklendi
import '../../domain/address_notifier.dart';

class LocationInfoScreen extends ConsumerWidget {
  const LocationInfoScreen({super.key});

  Future<void> _requestLocation(BuildContext context, WidgetRef ref) async {
    // 1️⃣ Location service açık mı?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      HapticFeedback.vibrate();
      Toasts.error(context, "Konum servisi kapalı, lütfen açın.");
      return;
    }

    // 2️⃣ Permission kontrol
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      HapticFeedback.vibrate();
      Toasts.error(context, "Konum izni reddedildi");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      HapticFeedback.heavyImpact();
      // 🎯 Kalıcı red durumunda kullanıcıyı ayarlar diyaloğuna yönlendirelim
      final openSettings = await PlatformDialogs.confirm(
        context,
        title: "Konum İzni Gerekli 📍",
        message: "Size en yakın paketleri gösterebilmemiz için konum iznine ihtiyacımız var. Ayarlardan açmak ister misiniz?",
        confirmText: "Ayarlara Git",
        cancelText: "Vazgeç",
      );

      if (openSettings) {
        await Geolocator.openAppSettings();
      }
      return;
    }

    // 3️⃣ Konumu al
    try {
      HapticFeedback.selectionClick();
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
      if (context.mounted) {
        context.push('/location-picker');
      }
    } catch (e) {
      HapticFeedback.vibrate();
      Toasts.error(context, "Konum alınırken bir hata oluştu.");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_rounded, size: 70, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Sana uygun sürpriz paketleri keşfetmek için konumunu seç.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: 'Mevcut Konumumu Kullan',
              onPressed: () => _requestLocation(context, ref),
              showPrice: false,
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                context.push('/location-picker');
              },
              child: const Text(
                'Haritadan seçeceğim',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}