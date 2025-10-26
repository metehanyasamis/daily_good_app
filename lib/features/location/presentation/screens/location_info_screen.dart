import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/widgets/custom_button.dart';

class LocationInfoScreen extends ConsumerWidget {
  const LocationInfoScreen({super.key});

  Future<void> _requestLocation(BuildContext context, WidgetRef ref) async {
    final status = await Permission.location.request();

    if (status == PermissionStatus.granted) {
      final position = await Geolocator.getCurrentPosition();
      debugPrint("Konum: ${position.latitude}, ${position.longitude}");

      // ✅ Riverpod states güncelle
      ref.read(appStateProvider.notifier).setLocationAccess(true);

      // ✅ Artık harita ekranına geç
      context.go('/map');
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
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Kullanıcı manuel seçim yapmak istiyor
                context.go('/map');
              },
              child: const Text('Kendim gireceğim'),
            ),
          ],
        ),
      ),
    );
  }
}
