/*
import 'package:geolocator/geolocator.dart';

import 'package:flutter/material.dart';

class LocationHelper {
  static Future<Position?> checkAndRequestLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnack(context, "Konum servisi kapalı, lütfen ayarlardan açın.");
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnack(context, "Konum izni reddedildi.");
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnack(context, "Konum izni kalıcı olarak reddedildi. Ayarlardan açmanız gerekiyor.");
      // Opsiyonel: Ayarları açtırabilirsin -> await Geolocator.openAppSettings();
      return null;
    }

    return await Geolocator.getCurrentPosition();
  }

  static void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }
}

 */

// core/utils/location_helper.dart
import 'package:geolocator/geolocator.dart';

enum LocationRequestResult {
  success,
  serviceOff,
  denied,
  deniedForever,
  error,
}

class LocationHelper {
  static Future<(LocationRequestResult, Position?)> requestCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return (LocationRequestResult.serviceOff, null);
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return (LocationRequestResult.denied, null);
      }

      if (permission == LocationPermission.deniedForever) {
        return (LocationRequestResult.deniedForever, null);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      return (LocationRequestResult.success, position);
    } catch (_) {
      return (LocationRequestResult.error, null);
    }
  }
}
