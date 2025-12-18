import 'package:flutter/material.dart';
import '../../data/model/working_hours_ui_model.dart';

class StoreWorkingHoursSection extends StatelessWidget {
  final List<WorkingHoursUiModel> hours;

  const StoreWorkingHoursSection({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    if (hours.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Çalışma Saatleri",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),

          ...hours.map(
                (h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(h.day),
                  Text(
                    h.display(),
                    style: const TextStyle(color: Colors.black54),
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
