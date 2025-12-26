// lib/core/utils/time_formatter.dart
class TimeFormatter {
  /// "11:50:00" veya "11:5" -> "11:50"
  static String hm(String? raw) {
    if (raw == null || raw.isEmpty) return '00:00';

    // Eğer saniyeli formatta geliyorsa (00:00:00) parçalayıp alalım
    if (raw.contains(':')) {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        // Saat ve dakikayı al, tek haneliyse başına 0 koy (Örn: 9:5 -> 09:05)
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
    }
    return raw;
  }

  static String range(String start, String end) {
    if (start.isEmpty && end.isEmpty) return 'Teslim saati bilgisi yok';
    return '${hm(start)} - ${hm(end)}'; // "Teslim:" ibaresini UI'da yönetmek daha esnektir
  }
}