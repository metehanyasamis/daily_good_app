// lib/features/stores/data/models/working_hours_model.dart

class WorkingHoursModel {
  final Map<String, WorkingHoursDay> days;

  WorkingHoursModel({required this.days});

  factory WorkingHoursModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return WorkingHoursModel(days: {});
    }

    final map = <String, WorkingHoursDay>{};

    json.forEach((key, value) {
      if (value != null) {
        map[key] = WorkingHoursDay.fromJson(value);
      }
    });

    return WorkingHoursModel(days: map);
  }

}

class WorkingHoursDay {
  final String start;
  final String end;

  WorkingHoursDay({required this.start, required this.end});

  factory WorkingHoursDay.fromJson(Map<String, dynamic> json) {
    return WorkingHoursDay(
      start: json['start'] ?? "",
      end: json['end'] ?? "",
    );
  }
}
