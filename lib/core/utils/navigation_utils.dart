import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

import '../../features/businessShop/data/model/businessShop_model.dart';

/// Açıklama:
/// openMap() - cihazın harita uygulamasında navigasyon başlatır.
///
/// [lat] ve [lng] koordinatlarını kullanır.
/// Opsiyonel [label] parametresi, hedef ismini gösterir.
/// Google Maps, Apple Maps (iOS) veya Web fallback destekler.
Future<void> openMap(double lat, double lng, {String? label}) async {
  final encodedLabel = Uri.encodeComponent(label ?? 'Konum');

  final Uri uri = Platform.isIOS
      ? Uri.parse("http://maps.apple.com/?q=$encodedLabel&ll=$lat,$lng")
      : Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Harita açılamadı: $uri');
  }
}

/// BusinessModel için kolay çağırım
Future<void> openBusinessMap(BusinessModel business) async {
  await openMap(
    business.latitude,
    business.longitude,
    label: business.name,
  );
}
