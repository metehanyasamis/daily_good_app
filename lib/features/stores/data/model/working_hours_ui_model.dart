class WorkingHoursUiModel {
  final String day;
  final String open;
  final String close;
  final bool isClosed; // 🔥 Bu alanı ekledik

  WorkingHoursUiModel({
    required this.day,
    required this.open,
    required this.close,
    this.isClosed = false, // Varsayılan olarak false
  });

  String display() {
    if (isClosed) {
      return "Kapalı"; // 🔥 Kapalıysa direkt Kapalı yazsın
    }
    if (open.isEmpty || close.isEmpty) {
      return "Belirtilmedi";
    }
    // API'den "09:00:00" gelirse "09:00" almak için substring güvenli hale getirildi
    try {
      final start = open.length >= 5 ? open.substring(0, 5) : open;
      final end = close.length >= 5 ? close.substring(0, 5) : close;
      return "$start - $end";
    } catch (e) {
      return "$open - $close";
    }
  }
}