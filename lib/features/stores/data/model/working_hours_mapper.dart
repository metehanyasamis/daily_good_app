// lib/features/stores/data/models/working_hours_mapper.dart

import 'package:daily_good/features/stores/data/model/working_hours_model.dart';
import 'package:daily_good/features/stores/data/model/working_hours_ui_model.dart';

extension WorkingHoursMapper on WorkingHoursModel {
  List<WorkingHoursUiModel> toUiList() {
    // Artık 'days' bir List olduğu için direkt .map kullanıyoruz
    return days.map((dayModel) {
      return WorkingHoursUiModel(
        // API'den gelen 'Pazartesi' gibi değerleri direkt kullanıyoruz
        day: dayModel.day,
        open: dayModel.openTime,
        close: dayModel.closeTime,
        isClosed: dayModel.isClosed,
      );
    }).toList();
  }
}


String _dayLabel(String key) {
  switch (key) {
    case 'monday':
      return 'Pazartesi';
    case 'tuesday':
      return 'Salı';
    case 'wednesday':
      return 'Çarşamba';
    case 'thursday':
      return 'Perşembe';
    case 'friday':
      return 'Cuma';
    case 'saturday':
      return 'Cumartesi';
    case 'sunday':
      return 'Pazar';
    default:
      return key;
  }
}
