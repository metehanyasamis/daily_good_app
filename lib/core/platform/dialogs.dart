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
      }) async {
    if (PlatformUtils.isIOS) {
      final res = await showCupertinoDialog<bool>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: destructive,
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
      return res ?? false;
    } else {
      final res = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelText)),
            TextButton(onPressed: () => Navigator.pop(context, true), child: Text(confirmText)),
          ],
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
        builder: (_) => CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            children: [
              const SizedBox(height: 8),
              CupertinoTextField(
                controller: controller,
                placeholder: hintText,
                keyboardType: keyboardType,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: Text(cancelText)),
            CupertinoDialogAction(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(confirmText)),
          ],
        ),
      );
    } else {
      return showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(hintText: hintText),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(cancelText)),
            TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: Text(confirmText)),
          ],
        ),
      );
    }
  }
}
