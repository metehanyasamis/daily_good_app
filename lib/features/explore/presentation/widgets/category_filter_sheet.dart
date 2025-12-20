import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import 'category_filter_option.dart';

class CategoryFilterSheet extends StatefulWidget {
  final CategoryFilterOption selected;
  final ValueChanged<CategoryFilterOption> onApply;

  const CategoryFilterSheet({
    super.key,
    required this.selected,
    required this.onApply,
  });

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late CategoryFilterOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      top: false,
      bottom: true, // 🔥 bottom bar altında kalmasın diye
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(context).viewPadding.bottom + 20, // 🔥
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Kategori Seç",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ...CategoryFilterOption.values.map((opt) {
              return RadioListTile<CategoryFilterOption>(
                title: Text(categoryLabel(opt)), // 👈 Ortak helper KULLANIYORUZ
                value: opt,
                groupValue: _selected,
                activeColor: AppColors.primaryDarkGreen,
                onChanged: (val) {
                  setState(() => _selected = val!);
                },
              );
            }).toList(),

            const SizedBox(height: 16),

            CustomButton(
              text: "Uygula",
              onPressed: () {
                widget.onApply(_selected);
              },
              showPrice: false,
            ),

            // 🔥 Bottom nav üstüne çıkması için ekstra boşluk
            SizedBox(height: bottomPad + 16),
          ],
        ),
      ),
    );
  }
}