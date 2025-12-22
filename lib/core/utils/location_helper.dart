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