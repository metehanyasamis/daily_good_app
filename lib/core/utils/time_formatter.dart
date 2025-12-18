// lib/core/utils/time_formatter.dart
class TimeFormatter {
  /// "11:50:00" -> "11:50"
  static String hm(String raw) {
    if (raw.isEmpty) return '';
    return raw.length >= 5 ? raw.substring(0, 5) : raw;
  }

  /// "11:50:00", "02:11:00" -> "11:50 - 02:11"
  static String range(String start, String end) {
    if (start.isEmpty && end.isEmpty) {
      return 'Teslim saati bilgisi yok';
    }
    if (start.isEmpty) return 'Teslim: ${hm(end)}';
    if (end.isEmpty) return 'Teslim: ${hm(start)}';

    return 'Teslim: ${hm(start)} - ${hm(end)}';
  }
}
