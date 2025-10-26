// lib/core/platform/haptics.dart
import 'package:flutter/services.dart';
import 'platform_utils.dart';

class Haptics {
  static Future<void> light() async {
    if (PlatformUtils.isIOS) {
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  static Future<void> success() async {
    // iOS “success” hissi için yakınlaştırma
    await medium();
  }

  static Future<void> error() async {
    await HapticFeedback.vibrate();
  }
}
