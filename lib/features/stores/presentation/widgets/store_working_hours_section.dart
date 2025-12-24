import 'package:flutter/material.dart';
import '../../data/model/working_hours_ui_model.dart';

class StoreWorkingHoursSection extends StatelessWidget {
  final List<WorkingHoursUiModel> hours;

  const StoreWorkingHoursSection({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    debugPrint("📦 [UI_BUILD] Gelen Saat Listesi Uzunluğu: ${hours.length}");
    if (hours.isEmpty) {
      debugPrint("🚫 [UI_EMPTY] Liste boş olduğu için SizedBox dönüyorum");
      return const SizedBox();
    }

    return Container(
      // Padding ve Margin ayarları Figma'ya göre güncellendi
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20), // İç boşluk biraz artırıldı
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Tasarımdaki gibi daha oval
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Çok hafif, modern bir gölge
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Çalışma Saatleri",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18, // Başlık biraz büyütüldü
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16), // Başlık ile liste arası açıldı

          ...hours.map(
                (h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8), // Satır araları ferahlatıldı
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    h.day,
                    style: TextStyle(
                      color: Colors.grey.shade700, // Gün isimleri biraz daha soluk
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    h.display(),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600, // Saatler daha belirgin
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}