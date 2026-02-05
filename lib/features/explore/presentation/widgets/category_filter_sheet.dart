import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import 'category_filter_option.dart';

class CategoryFilterSheet extends StatefulWidget {
  final String? selectedId;
  final List<dynamic>? backendCategories; // Backend listesi gelirse buraya
  final ValueChanged<Map<String, String?>> onApply;

  const CategoryFilterSheet({
    super.key,
    this.selectedId,
    this.backendCategories,
    required this.onApply,
  });

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  String? _tempSelectedId;

  @override
  void initState() {
    super.initState();
    _tempSelectedId = widget.selectedId;
  }

  @override
  Widget build(BuildContext context) {

    // Backend tek kaynak: liste tamamen backend'den (Tümü dahil). Fallback: enum listesi.
    final List<Map<String, String>> items =
    widget.backendCategories != null
        ? widget.backendCategories!.map((cat) {
      final d = cat as dynamic;
      return {
        'id': d.id?.toString() ?? '',
        'name': (d.name ?? d.title ?? d.id ?? '').toString(),
      };
    }).toList()
        : CategoryFilterOption.values.map((opt) {
      return {
        'id': opt == CategoryFilterOption.all ? '' : opt.name,
        'name': categoryLabel(opt),
      };
    }).toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // SafeArea bottom: true diyerek sistem barına çarpmasını engelliyoruz
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text("Kategori Seç", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: items.map((item) {
                    final isSelected = _tempSelectedId == item['id'];
                    return GestureDetector(
                      onTap: () => setState(() => _tempSelectedId = item['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryDarkGreen.withValues(alpha: 0.05) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent,
                              width: 1.5
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['name'] ?? '',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? AppColors.primaryDarkGreen : Colors.black87
                              ),
                            ),
                            Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                color: isSelected ? AppColors.primaryDarkGreen : Colors.grey.shade300,
                                size: 22
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // BUTON ALANI
            Padding(
              // Buradaki son değeri (80) senin Bottom Bar'ının yüksekliğine göre ayarlıyoruz.
              // 80 birim genelde yüzen barın üstünde kalması için yeterlidir.
                padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 120),
                child: CustomButton(
                  text: "Filtreleri Uygula",
                  onPressed: () {
                    final selectedItem = items.firstWhere(
                          (e) => e['id'] == (_tempSelectedId ?? ''),
                      orElse: () => items.first,
                    );
                    widget.onApply(selectedItem);
                  },

                  showPrice: false,
                ),
            ),
          ],
        ),
      ),
    );
  }
}