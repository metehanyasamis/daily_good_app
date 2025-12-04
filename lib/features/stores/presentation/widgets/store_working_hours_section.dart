// lib/features/stores/presentation/widgets/store_working_hours_section.dart

import 'package:flutter/material.dart';

import '../../data/model/working_hours_model.dart';

class StoreWorkingHoursSection extends StatelessWidget {
  final List<WorkingHoursModel> hours;

  const StoreWorkingHoursSection({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
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
          const Text("Çalışma Saatleri",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

          ...hours.map(
                (h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(h.day, style: const TextStyle(fontSize: 14)),
                  Text("${h.open} - ${h.close}",
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
