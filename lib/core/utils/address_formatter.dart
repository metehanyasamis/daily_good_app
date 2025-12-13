String formatShortAddress(String fullAddress) {
  // Örnek full:
  // "Nal Sk. No:7, Yeldegirmeni, Kadikoy"

  if (fullAddress.isEmpty) return 'Konum Seç';

  final parts = fullAddress.split(',');

  // İlk parça genelde: "Nal Sk. No:7"
  final first = parts.first.trim();

  // Güvenlik: No yoksa sadece sokak
  return first;
}
