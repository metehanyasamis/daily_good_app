// lib/core/platform/toasts.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

class Toasts {
  static void show(BuildContext context, String message, {bool isError = false}) {
    if (PlatformUtils.isIOS) {
      // iOS'ta diyalog yerine "Cupertino-style" şık bir overlay yapalım
      _showCupertinoToast(context, message, isError);
    } else {
      // Android'de floating SnackBar harikadır
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
        ),
      );
    }
  }

  static void success(BuildContext context, String message) => show(context, message, isError: false);
  static void error(BuildContext context, String message) => show(context, message, isError: true);

  // iOS'ta akışı bozmayan taze bir Toast
  static void _showCupertinoToast(BuildContext context, String message, bool isError) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Center( // iOS'ta orta kısım çok popülerdir
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.black87.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isError ? CupertinoIcons.xmark_circle : CupertinoIcons.check_mark_circled,
                color: isError ? CupertinoColors.systemRed : CupertinoColors.systemGreen,
                size: 40,
              ),
              const SizedBox(height: 12),
              Material( // Text stili için
                color: Colors.transparent,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }
}