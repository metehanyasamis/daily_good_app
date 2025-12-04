// lib/features/stores/data/models/working_hours_model.dart

class WorkingHoursModel {
  final String day;
  final String open;
  final String close;

  WorkingHoursModel({
    required this.day,
    required this.open,
    required this.close,
  });

  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    return WorkingHoursModel(
      day: json['day'] ?? "",
      open: json['open'] ?? "",
      close: json['close'] ?? "",
    );
  }
}

// 🔥 Çalışan extension
extension WorkingHoursFormatter on WorkingHoursModel {
  String toDisplayString() {
    if (open.isEmpty || close.isEmpty) {
      return "Çalışma saatleri belirtilmedi";
    }

    // 09:00 formatına çevir
    final formattedOpen = open.substring(0, 5);
    final formattedClose = close.substring(0, 5);

    return "$formattedOpen - $formattedClose";
  }
}
