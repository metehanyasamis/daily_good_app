// lib/core/platform/permissions_service.dart
import 'package:permission_handler/permission_handler.dart';
import '../../features/notification/presentation/logic/notification_permission.dart';
import '../data/prefs_service.dart';
import 'platform_utils.dart';

class PermissionsService {
  static Future<bool> ensureLocation() async {
    // 1. Mevcut duruma bak
    var status = await Permission.location.status;

    // 2. Eğer zaten izin verilmişse direkt true dön
    if (status.isGranted) return true;

    // 3. Daha önce sorduk mu kontrol et
    final hasAsked = await PrefsService.getHasAskedLocation();

    // 4. Eğer daha önce sorduysak ve hala izin yoksa, sistem diyaloğunu tekrar açma
    // (Kullanıcıyı ayarlara yönlendirmek başka bir konu, ama burada sistem diyaloğunu engelliyoruz)
    if (hasAsked && !status.isGranted) {
      return false;
    }

    // 5. İlk kez soruyoruz veya durumu netleştirmemiz lazım
    status = await Permission.location.request();

    // 6. Sorduğumuzu kaydet
    await PrefsService.setHasAskedLocation(true);

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

  static Future<void> ensureNotifications() async {
    await NotificationPermission.request();
  }
}
