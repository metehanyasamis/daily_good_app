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

