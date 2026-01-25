class TimeFormatter {
  /// "11:50:00" -> "11:50"
  static String hm(String? raw) {
    if (raw == null || raw.isEmpty) return '00:00';
    if (raw.contains(':')) {
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
    }
    return raw;
  }

  /// İki saat arasını formatlar
  static String range(String start, String end) {
    if (start.isEmpty && end.isEmpty) return 'Teslim saati bilgisi yok';
    return '${hm(start)} - ${hm(end)}';
  }

  /// Bugün/Yarın destekli gelişmiş formatlayıcı
  static String formatDeliveryDate(String? startDate, String? startHour, String? endHour) {
    if (startDate == null || startDate.isEmpty) return "Teslimat saati";
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final deliveryDate = DateTime.parse(startDate);
      final pureDeliveryDate = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);

      final String timeRange = "${hm(startHour)} – ${hm(endHour)}";

      if (pureDeliveryDate.isAtSameMomentAs(today)) return "Bugün $timeRange";
      if (pureDeliveryDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) return "Yarın $timeRange";

      final List<String> months = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
      return "${deliveryDate.day} ${months[deliveryDate.month]} $timeRange";
    } catch (e) {
      return "Teslimat: ${hm(startHour)} – ${hm(endHour)}";
    }
  }
}