// lib/core/platform/permissions_service.dart
import 'package:permission_handler/permission_handler.dart';
import 'platform_utils.dart';

class PermissionsService {
  static Future<bool> ensureLocation() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> ensureCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> ensurePhotos() async {
    // iOS: photos, Android: storage/mediaLibrary projene göre
    final status = PlatformUtils.isIOS
        ? await Permission.photos.request()
        : await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> ensureNotifications() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }
}
