import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_state_provider.dart';

class LocationMapScreen extends ConsumerWidget {
  const LocationMapScreen({super.key});

  /// ---------------------------------------------------------------
  /// 📍 Konumu onayla (harita yok – data backend / state üzerinden)
  /// ---------------------------------------------------------------
  Future<void> _confirmLocation(
      BuildContext context,
      WidgetRef ref,
      ) async {
    // Şimdilik mock / state içinden gelecek varsayılan değer
    // (ileride backend veya location service burayı dolduracak)
    const latitude = 40.9929;
    const longitude = 29.0270;

    final ok = await ref
        .read(appStateProvider.notifier)
        .setUserLocation(latitude, longitude);

    if (!ok) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Konum güncellenemedi")),
        );
      }
      return;
    }

    if (context.mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konum Onayı"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 72,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              "Konumunuzu doğrulamak üzeresiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _confirmLocation(context, ref),
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
    );
  }
}
