
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/platform/toasts.dart';
import '../../../../core/platform/dialogs.dart';
import '../../domain/address_notifier.dart';

class LocationInfoScreen extends ConsumerStatefulWidget {
  const LocationInfoScreen({super.key});

  @override
  ConsumerState<LocationInfoScreen> createState() =>
      _LocationInfoScreenState();
}

class _LocationInfoScreenState
    extends ConsumerState<LocationInfoScreen> {

  // --------------------------------------------------
  // 📍 ANA AKIŞ
  // --------------------------------------------------
  Future<void> _requestLocation() async {
    // 🔒 ASYNC ÖNCESİ CONTEXT GÜVENE AL
    final ctx = context;

    // 1️⃣ Location service açık mı?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      HapticFeedback.vibrate();
      if (!mounted) return;
      Toasts.error(ctx, "Konum servisi kapalı, lütfen açın.");
      return;
    }

    // 2️⃣ Permission kontrol
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      HapticFeedback.vibrate();
      if (!mounted) return;
      Toasts.error(ctx, "Konum izni reddedildi");
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      HapticFeedback.heavyImpact();
      if (!mounted) return;

      final openSettings = await PlatformDialogs.confirm(
        ctx,
        title: "Konum İzni Gerekli 📍",
        message:
        "Size en yakın paketleri gösterebilmemiz için konum iznine ihtiyacımız var.",
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      ref.read(addressProvider.notifier).setAddress(
        lat: position.latitude,
        lng: position.longitude,
        title: 'Mevcut Konum',
      );

      if (!mounted) return;
      ctx.push('/location-picker');
    } catch (e) {
      if (!mounted) return;
      Toasts.error(ctx, "Konum alınırken bir hata oluştu.");
    }
  }

  // --------------------------------------------------
  // 🧱 UI
  // --------------------------------------------------
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
              onPressed: _requestLocation,
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

// lib/features/location/presentation/screens/location_info_screen.dart

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

