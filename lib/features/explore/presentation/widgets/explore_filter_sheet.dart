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
  final Function(ExploreFilterOption) onApply;

  const ExploreFilterSheet({
    super.key,
    required this.selected,
    required this.onApply,
  });

  @override
  State<ExploreFilterSheet> createState() => _ExploreFilterSheetState();
}

class _ExploreFilterSheetState extends State<ExploreFilterSheet> {
  late ExploreFilterOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filtrele',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildOption(ExploreFilterOption.recommended, 'Önerilen'),
            _buildOption(ExploreFilterOption.distance, 'Mesafeye Göre'),
            _buildOption(ExploreFilterOption.price, 'Fiyata Göre'),
            _buildOption(ExploreFilterOption.rating, 'Değerlendirmeye Göre'),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Uygula',
              onPressed: () {
                widget.onApply(_selectedOption);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(ExploreFilterOption value, String label) {
    return RadioListTile<ExploreFilterOption>(
      title: Text(label),
      value: value,
      groupValue: _selectedOption,
      onChanged: (val) {
        setState(() {
          _selectedOption = val!;
        });
      },
      activeColor: AppColors.primaryDarkGreen,
    );
  }
}
