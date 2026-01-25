// lib/core/platform/platform_widgets.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

class PlatformWidgets {
  /// 🌀 Platforma özel yükleme ikonu
  /// Android: CircularProgressIndicator
  /// iOS: CupertinoActivityIndicator
// lib/core/platform/platform_widgets.dart içerisindeki metodun güncel hali:
  static Widget loader({
    double radius = 10,
    Color? color,
    double strokeWidth = 3.0, // Android için varsayılan değer
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoActivityIndicator(radius: radius, color: color);
    } else {
      return CircularProgressIndicator(
        strokeWidth: strokeWidth, // 🎯 Buraya bağladık
        valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
      );
    }
  }

/// 🔘 İleride gerekirse: Platforma özel Switch, Slider vb. buraya eklenebilir.
}