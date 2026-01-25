import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../screens/explore_list_screen.dart';

// ENUM BURADA KALSIN (Hataları çözmek için diğer dosyalarda burayı import edeceğiz)
enum ExploreFilterOption {
  recommended,
  distance,
  price,
  rating,
  hemenYaninda,
  yeni,
  sonSans,
  bugun,
  yarin,
}

class ExploreFilterSheet extends StatefulWidget {
  final ExploreFilterOption selected;
  final SortDirection direction;
  final List<ExploreFilterOption> availableOptions;
  final Function(ExploreFilterOption opt, SortDirection dir) onApply;

  const ExploreFilterSheet({
    super.key,
    required this.selected,
    required this.direction,
    required this.availableOptions,
    required this.onApply,
  });

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late ExploreFilterOption _tempSelected;
  late SortDirection _tempDirection;

  @override
  void initState() {
    super.initState();
    _tempSelected = widget.selected;
    _tempDirection = widget.direction;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text("Sırala", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),

          // Sıralama Seçenekleri (Senin orijinal card yapın)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: widget.availableOptions.map((opt) {
                final isSelected = _tempSelected == opt;
                return GestureDetector(
                  onTap: () => setState(() => _tempSelected = opt),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryDarkGreen.withValues(alpha: 0.05) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _labelFor(opt),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primaryDarkGreen : Colors.black87,
                          ),
                        ),
                        Icon(isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                            color: isSelected ? AppColors.primaryDarkGreen : Colors.grey.shade300, size: 22),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(height: 32, indent: 24, endIndent: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Sıralama Yönü", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                Container(
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _directionButton(SortDirection.ascending, Icons.arrow_upward, "Artan"),
                      _directionButton(SortDirection.descending, Icons.arrow_downward, "Azalan"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 85),
            child: CustomButton(
              text: "Sıralamayı Uygula",
              onPressed: () => widget.onApply(_tempSelected, _tempDirection),
              showPrice: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _directionButton(SortDirection dir, IconData icon, String label) {
    final isSelected = _tempDirection == dir;
    return GestureDetector(
      onTap: () => setState(() => _tempDirection = dir),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  String _labelFor(ExploreFilterOption opt) {
    switch (opt) {
      case ExploreFilterOption.recommended: return "Önerilen";
      case ExploreFilterOption.distance: return "Mesafe";
      case ExploreFilterOption.price: return "Fiyat";
      case ExploreFilterOption.rating: return "Puan";
      case ExploreFilterOption.hemenYaninda: return "Hemen Yanında";
      case ExploreFilterOption.yeni: return "Yeni";
      case ExploreFilterOption.sonSans: return "Son Şans";
      case ExploreFilterOption.bugun: return "Bugün";
      case ExploreFilterOption.yarin: return "Yarın";
    }
  }
}