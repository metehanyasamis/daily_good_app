// lib/features/stores/presentation/models/working_hours_ui_model.dart

class WorkingHoursUiModel {
  final String day;
  final String open;
  final String close;

  WorkingHoursUiModel({
    required this.day,
    required this.open,
    required this.close,
  });

  String display() {
    if (open.isEmpty || close.isEmpty) {
      return "Belirtilmedi";
    }
    return "${open.substring(0, 5)} - ${close.substring(0, 5)}";
  }
}
