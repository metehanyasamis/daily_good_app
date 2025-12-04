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
