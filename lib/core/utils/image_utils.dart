// lib/core/utils/image_utils.dart (veya uygun bir util dosyan)
// İstersen mevcut normalizeImageUrl yerine bunu kullanabilirsin.

String? sanitizeImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;

  // Eğer birden fazla 'http'/'https' varsa sonuncusunu al (ör: .../storage/https://via...)
  final httpsIndex = s.lastIndexOf('https://');
  final httpIndex = s.lastIndexOf('http://');
  String candidate = s;
  if (httpsIndex > 0) {
    candidate = s.substring(httpsIndex);
  } else if (httpIndex > 0) {
    candidate = s.substring(httpIndex);
  }

  // Parse ve validasyon
  final uri = Uri.tryParse(candidate);
  if (uri == null) return null;
  if (!(uri.scheme == 'http' || uri.scheme == 'https')) return null;

  // Opsiyonel: problem çıkaran veya güvenilmeyen hostları engelle
  final blockedHosts = <String>{
    'via.placeholder.com', // dev ortamda DNS sorunu oluyorsa bloke edilebilir
    // 'example-problem-host.com', // ihtiyaç varsa ekleyin
  };
  if (blockedHosts.contains(uri.host)) return null;

  return candidate;
}