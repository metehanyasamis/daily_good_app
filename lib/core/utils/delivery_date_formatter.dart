String formatDeliveryDate(String? startDate, String? startHour, String? endHour) {
  if (startDate == null || startDate.isEmpty) return "Teslimat saati";

  try {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deliveryDate = DateTime.parse(startDate);
    final pureDeliveryDate = DateTime(deliveryDate.year, deliveryDate.month, deliveryDate.day);

    final String timeRange = "${startHour?.substring(0, 5) ?? ''} – ${endHour?.substring(0, 5) ?? ''}";

    if (pureDeliveryDate.isAtSameMomentAs(today)) {
      return "Bugün $timeRange";
    } else if (pureDeliveryDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
      return "Yarın $timeRange";
    } else {
      // Örn: 15 Ocak 12:00 – 14:00
      final List<String> months = ["", "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
      return "${deliveryDate.day} ${months[deliveryDate.month]} $timeRange";
    }
  } catch (e) {
    return "Teslimat: $startHour – $endHour";
  }
}