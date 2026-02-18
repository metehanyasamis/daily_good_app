import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

class CategoryFilterSheet extends StatefulWidget {
  final String? selectedId;
  final List<dynamic>? backendCategories;
  final ValueChanged<Map<String, dynamic>> onApply; // Map tipini dynamic yaptım esneklik için

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
    _tempSelectedId = _normalizeId(widget.selectedId);
  }

  String? _normalizeId(dynamic id) {
    if (id == null) return null;
    final str = id.toString().trim();
    if (str.isEmpty || str.toLowerCase() == "null") return null;
    return str;
  }

  @override
  Widget build(BuildContext context) {
    // 1. ADIM: Listeyi oluştururken Backend'den gelen hatalı "Tümü"yü süzüyoruz.
    List<Map<String, dynamic>> items = [];

    // En başa her zaman bizim MANUEL ve DOĞRU çalışan "Tümü"yü ekliyoruz.
    items.add({'id': null, 'name': 'Tümü'});

    if (widget.backendCategories != null) {
      for (var cat in widget.backendCategories!) {
        final d = cat as dynamic;
        final String name = (d.name ?? d.title ?? "").toString();

        // KONTROL: Eğer gelen kategori ismi "Tümü" veya "All" ise listeye EKLEME.
        // Çünkü biz yukarıda manuel ekledik zaten.
        if (name.toLowerCase() == 'tümü' || name.toLowerCase() == 'all') {
          continue;
        }

        final String? finalId = _normalizeId(d.id);
        items.add({
          'id': finalId,
          'name': name,
        });
      }
    }
    // Eğer backend listesi yoksa enum'dan doldur (Eski yapı desteği)
    else {
      // Burayı enum yapına göre açabilirsin, şimdilik boş geçiyorum logic bozulmasın diye.
    }

    final double bottomPadding = MediaQuery.of(context).padding.bottom + 90;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Sheet'in maksimum yüksekliğini sınırla (Ekranın %85'i)
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Kategori Seç",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.grey), // Şık bir çizgi

          // LİSTE ALANI
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final String? itemId = item['id'];
                final String itemName = item['name'] ?? '';

                final bool isSelected = _tempSelectedId == itemId;

                return GestureDetector(
                  onTap: () {
                    setState(() => _tempSelectedId = itemId);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryDarkGreen.withOpacity(0.08) // values.alpha yerine opacity daha güvenli
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryDarkGreen : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.primaryDarkGreen : Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, color: AppColors.primaryDarkGreen, size: 22)
                        else
                          Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 22),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // BUTON ALANI (Düzeltilmiş Padding)
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: bottomPadding, // ✅ İŞTE ÇÖZÜM BURADA
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: CustomButton(
              text: "Filtreleri Uygula",
              onPressed: () {
                final selectedItem = items.firstWhere(
                      (e) => e['id'] == _tempSelectedId,
                  orElse: () => {'id': null, 'name': 'Tümü'},
                );
                widget.onApply(selectedItem);
              },
              showPrice: false,
            ),
          ),
        ],
      ),
    );
  }
}