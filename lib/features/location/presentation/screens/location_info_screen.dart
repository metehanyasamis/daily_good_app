
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/platform/dialogs.dart';
import '../../../../core/utils/location_helper.dart';
import '../../domain/address_notifier.dart';

class LocationInfoScreen extends ConsumerStatefulWidget {
  const LocationInfoScreen({super.key});

  @override
  ConsumerState<LocationInfoScreen> createState() =>
      _LocationInfoScreenState();
}

class _LocationInfoScreenState
    extends ConsumerState<LocationInfoScreen> {

  /// --------------------------------------------------
  /// 🎯 BUTTON HANDLER — UI KONTROLÜ TAMAMEN BURADA
  /// --------------------------------------------------
  Future<void> _handleUseCurrentLocation() async {
    final (result, position) =
    await LocationHelper.requestCurrentLocation();

    if (!mounted) return;

    switch (result) {
      case LocationRequestResult.success:
        HapticFeedback.selectionClick();

        ref.read(addressProvider.notifier).setAddress(
          lat: position!.latitude,
          lng: position.longitude,
          title: 'Mevcut Konum',
        );

        context.push('/location-picker');
        break;

      case LocationRequestResult.serviceOff:
        HapticFeedback.vibrate();
        Toasts.error(context, "Konum servisi kapalı, lütfen açın.");
        break;

      case LocationRequestResult.denied:
        HapticFeedback.vibrate();
        Toasts.error(context, "Konum izni reddedildi.");
        break;

      case LocationRequestResult.deniedForever:
        HapticFeedback.heavyImpact();

        final openSettings = await PlatformDialogs.confirm(
          context,
          title: "Konum İzni Gerekli 📍",
          message:
          "Size en yakın paketleri gösterebilmemiz için konum iznine ihtiyacımız var.",
          confirmText: "Ayarlara Git",
          cancelText: "Vazgeç",
        );

        if (openSettings) {
          await Geolocator.openAppSettings();
        }
        break;

      case LocationRequestResult.error:
        HapticFeedback.vibrate();
        Toasts.error(context, "Konum alınırken bir hata oluştu.");
        break;
    }
  }

  /// --------------------------------------------------
  /// 🧱 UI
  /// --------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 70,
              color: Colors.green,
            ),
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
              onPressed: _handleUseCurrentLocation,
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

*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/platform/dialogs.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../core/theme/app_theme.dart'; // ✅ AppColors için eklendi
import '../../domain/address_notifier.dart';

class LocationInfoScreen extends ConsumerStatefulWidget {
  const LocationInfoScreen({super.key});

  @override
  ConsumerState<LocationInfoScreen> createState() => _LocationInfoScreenState();
}

class _LocationInfoScreenState extends ConsumerState<LocationInfoScreen> {

  Future<void> _handleUseCurrentLocation() async {
    final (result, position) = await LocationHelper.requestCurrentLocation();
    if (!mounted) return;

    switch (result) {
      case LocationRequestResult.success:
        HapticFeedback.selectionClick();
        ref.read(addressProvider.notifier).setAddress(
          lat: position!.latitude,
          lng: position.longitude,
          title: 'Mevcut Konum',
        );
        context.push('/location-picker');
        break;
      case LocationRequestResult.serviceOff:
        HapticFeedback.vibrate();
        Toasts.error(context, "Konum servisi kapalı, lütfen açın.");
        break;
      case LocationRequestResult.denied:
        HapticFeedback.vibrate();
        Toasts.error(context, "Konum izni reddedildi.");
        break;
      case LocationRequestResult.deniedForever:
        HapticFeedback.heavyImpact();
        final openSettings = await PlatformDialogs.confirm(
          context,
          title: "Konum İzni Gerekli 📍",
          message: "Size en yakın paketleri gösterebilmemiz için konum iznine ihtiyacımız var.",
          confirmText: "Ayarlara Git",
          cancelText: "Vazgeç",
        );
        if (openSettings) {
          await Geolocator.openAppSettings();
        }
        break;
      case LocationRequestResult.error:
        HapticFeedback.vibrate();
        Toasts.error(context, "Konum alınırken bir hata oluştu.");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height * 0.55;

    return Scaffold(
      // ✅ Standart Arka Plan
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Konum Seçimi",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        // Eğer geri dönülmesini istemiyorsan leading'i boş bırakabilirsin
        automaticallyImplyLeading: false,
      ),
      body: Center( // ✅ Kartı ekranda ortalar
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: // LocationInfoScreen body içindeki Container
          Container(
            width: double.infinity,
            height: cardHeight,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // İçeriği dağıtır
              children: [
                const Icon(Icons.location_on_rounded, size: 64, color: AppColors.primaryDarkGreen),
                Column(
                  children: [
                    const Text(
                      'Sana uygun fırsatları keşfetmek için konumunu seç.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Sana en yakın paketleri listelemek ve israfı beraber önlemek için konumuna ihtiyacımız var.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CustomButton(
                      text: 'Mevcut Konumumu Kullan',
                      onPressed: _handleUseCurrentLocation,
                      showPrice: false,
                    ),
                    TextButton(
                      onPressed: () => context.push('/location-picker'),
                      child: const Text(
                        'Haritadan manuel seçeceğim',
                        style: TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}