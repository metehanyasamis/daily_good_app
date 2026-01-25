import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

Future<void> openMap({
  double? latitude,
  double? longitude,
  String? address,
  String? label,
}) async {
  Uri? uri;

  // ===============================
  // ANDROID
  // ===============================
  if (Platform.isAndroid) {
    // 1️⃣ KOORDİNAT VARSA
    if (latitude != null && longitude != null) {
      final encodedLabel = Uri.encodeComponent(label ?? 'Konum');

      // 🔥 1. deneme → Google Maps Navigation
      final googleNav = Uri.parse(
        'google.navigation:q=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleNav)) {
        await launchUrl(
          googleNav,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // 🔥 2. deneme → geo intent
      final geoUri = Uri.parse(
        'geo:$latitude,$longitude?q=$latitude,$longitude($encodedLabel)',
      );

      if (await canLaunchUrl(geoUri)) {
        await launchUrl(
          geoUri,
          mode: LaunchMode.externalApplication,
        );
        return;
      }

      // 🔥 3. deneme → WEB fallback (GARANTİ)
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
    }

    // 2️⃣ ADRES FALLBACK
    if (uri == null && address != null && address.isNotEmpty) {
      final encoded = Uri.encodeComponent(address);
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded',
      );
    }
  }

  // ===============================
  // IOS
  // ===============================
  else if (Platform.isIOS) {
    if (latitude != null && longitude != null) {
      final encodedLabel = Uri.encodeComponent(label ?? 'Konum');
      uri = Uri.parse(
        'http://maps.apple.com/?ll=$latitude,$longitude&q=$encodedLabel',
      );
    } else if (address != null && address.isNotEmpty) {
      final encoded = Uri.encodeComponent(address);
      uri = Uri.parse(
        'http://maps.apple.com/?q=$encoded',
      );
    }
  }

  // ===============================
  // FINAL LAUNCH
  // ===============================
  if (uri == null) return;

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    debugPrint('❌ Map launch failed (final): $uri');
  }
}
