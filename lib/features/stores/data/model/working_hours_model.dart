class WorkingHoursModel {
  // Veriyi Map yerine direkt Liste olarak tutmak API yapına daha uygun
  final List<WorkingDayModel> days;

  WorkingHoursModel({required this.days});

  // Loglarda gördüğümüz Liste yapısını parse eden ana metod
  factory WorkingHoursModel.fromList(List<dynamic> list) {
    return WorkingHoursModel(
      days: list.map((e) {
        final item = e as Map<String, dynamic>;
        return WorkingDayModel(
          day: item['day']?.toString() ?? '',
          // API'den gelen start_time ve end_time isimlerini kullanıyoruz
          openTime: item['start_time']?.toString() ?? '',
          closeTime: item['end_time']?.toString() ?? '',
          isClosed: item['is_closed'] == true || item['is_closed'] == 1,
        );
      }).toList(),
    );
  }

  // Eğer nadiren Map (Sözlük) gelirse diye yedek metod
  factory WorkingHoursModel.fromJson(Map<String, dynamic> json) {
    final List<WorkingDayModel> tempDays = [];
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        tempDays.add(WorkingDayModel(
          day: key,
          openTime: value['start'] ?? '',
          closeTime: value['end'] ?? '',
          isClosed: false,
        ));
      }
    });
    return WorkingHoursModel(days: tempDays);
  }
}

class WorkingDayModel {
  final String day;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  WorkingDayModel({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  // UI'da görünecek format: "09:00 - 22:00" veya "Kapalı"
  String display() {
    if (isClosed) return "Kapalı";
    if (openTime.isEmpty || closeTime.isEmpty) return "Belirtilmemiş";
    return "$openTime - $closeTime";
  }
}