import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

class AppPlatformBehavior {
  /// 🪧 Bildirim mesajı (snackbar/alert)
  static void showMessage(BuildContext context, String message) {
    if (PlatformUtils.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Bilgi'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('Tamam'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 📱 Navigasyon geçiş animasyonları
  static PageRoute<T> platformPageRoute<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoPageRoute(builder: builder, settings: settings);
    } else {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
  }

  /// 🧭 Geri dönüş doğrulama (örneğin formda değişiklik varsa)
  static Future<bool> confirmExit(BuildContext context) async {
    if (PlatformUtils.isIOS) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Emin misiniz?'),
          content: const Text('Yaptığınız değişiklikler kaybolacak.'),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Evet'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            CupertinoDialogAction(
              child: const Text('Vazgeç'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      );
      return result ?? false;
    } else {
      final result = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Emin misiniz?'),
          content: const Text('Yaptığınız değişiklikler kaybolacak.'),
          actions: [
            TextButton(
              child: const Text('Vazgeç'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Evet'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
      return result ?? false;
    }
  }
}
