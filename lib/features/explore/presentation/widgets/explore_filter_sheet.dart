import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_button.dart';

enum ExploreFilterOption {
  recommended,
  distance,
  price,
  rating,
}

String sortLabel(ExploreFilterOption o) {
  switch (o) {
    case ExploreFilterOption.recommended:
      return "Önerilen";
    case ExploreFilterOption.distance:
      return "Mesafe";
    case ExploreFilterOption.price:
      return "Fiyat";
    case ExploreFilterOption.rating:
      return "Puan";
  }
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Sırala",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...ExploreFilterOption.values.map((o) {
            return RadioListTile(
              value: o,
              groupValue: _selected,
              title: Text(sortLabel(o)),
              onChanged: (v) => setState(() => _selected = v!),
            );
          }),

          const SizedBox(height: 16),

          CustomButton(
            text: "Uygula",
            onPressed: () => widget.onApply(_selected),
            showPrice: false,
          ),
        ],
      ),
    );
  }
}

