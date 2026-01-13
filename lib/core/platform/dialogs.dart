// lib/core/platform/dialogs.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

class PlatformDialogs {
  static Future<bool> confirm(
      BuildContext context, {
        required String title,
        required String message,
        String confirmText = 'Evet',
        String cancelText = 'Vazgeç',
        bool destructive = false,
        bool barrierDismissible = true,
      }) async {
    if (PlatformUtils.isIOS) {
      final res = await showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        useRootNavigator: true, // 🚀 GoRouter stack'ini bozmaması için şart
        builder: (ctx) => CupertinoAlertDialog( // 🎯 Buradaki 'ctx' hayati önemde
          title: Text(title),
          content: Text(message),
          actions: [
            if (cancelText.isNotEmpty)
              CupertinoDialogAction(
                // ✅ 'context' değil 'ctx' kullanıyoruz
                onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false),
                child: Text(cancelText),
              ),
            CupertinoDialogAction(
              isDestructiveAction: destructive,
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
      return res ?? false;
    } else {
      final res = await showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        useRootNavigator: true, // 🚀 Şart
        builder: (ctx) => PopScope(
          canPop: barrierDismissible,
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              if (cancelText.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(false),
                  child: Text(cancelText),
                ),

              if (destructive)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
                  child: Text(confirmText),
                )
              else
                TextButton(
                  onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(true),
                  child: Text(confirmText),
                ),
            ],
          ),
        ),
      );
      return res ?? false;
    }
  }

  static Future<String?> prompt(
      BuildContext context, {
        required String title,
        String hintText = '',
        String confirmText = 'Tamam',
        String cancelText = 'İptal',
        TextInputType keyboardType = TextInputType.text,
      }) async {
    final controller = TextEditingController();
    if (PlatformUtils.isIOS) {
      return showCupertinoDialog<String>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: CupertinoTextField(
              controller: controller,
              placeholder: hintText,
              keyboardType: keyboardType,
              autofocus: true,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(controller.text.trim()),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      return showDialog<String>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofocus: true,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(controller.text.trim()),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    }
  }
}