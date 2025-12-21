String? sanitizeImageUrl(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;

  // 1. Durum: İç içe geçmiş bozuk URL yapısını ayıkla
  // Eğer string içinde bir yerde 'http' başlıyorsa (başta değilse bile),
  // o noktadan sonrasını alıyoruz.
  if (s.contains('http') && s.lastIndexOf('http') > 0) {
    return s.substring(s.lastIndexOf('http'));
  }

  // 2. Durum: Zaten temiz bir tam URL (Kategorilerdeki gibi)
  if (s.startsWith('http://') || s.startsWith('https://')) {
    return s;
  }

  // 3. Durum: Sadece dosya yolu (relative path) gelmesi
  final cleanPath = s.startsWith('/') ? s.substring(1) : s;
  return 'https://dailygood.dijicrea.net/storage/$cleanPath';
}