import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';

enum ExploreFilterOption {
  recommended,
  distance,
  price,
  rating,
}

class ExploreFilterSheet extends StatefulWidget {
  final ExploreFilterOption selected;
  final ValueChanged<ExploreFilterOption> onApply;

  const ExploreFilterSheet({
    super.key,
    required this.selected,
    required this.onApply,
  });

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late ExploreFilterOption _selected;

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
      bottom: true,
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
              'Sırala',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _option(ExploreFilterOption.recommended, "Önerilen"),
            _option(ExploreFilterOption.distance, "Mesafe"),
            _option(ExploreFilterOption.price, "Fiyat"),
            _option(ExploreFilterOption.rating, "Puan"),

            const SizedBox(height: 24),

            CustomButton(
              text: "Uygula",
              onPressed: () {
                widget.onApply(_selected);
                Navigator.pop(context);
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

  Widget _option(ExploreFilterOption opt, String label) {
    return RadioListTile(
      value: opt,
      groupValue: _selected,
      activeColor: AppColors.primaryDarkGreen,
      title: Text(label),
      onChanged: (v) => setState(() => _selected = v!),
    );
  }
}
