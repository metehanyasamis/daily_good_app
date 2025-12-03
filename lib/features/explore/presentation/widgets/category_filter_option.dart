import 'package:daily_good/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum CategoryFilterOption {
  all,
  food,
  bakery,
  breakfast,
  market,
  vegetarian,
  vegan,
  glutenFree,
}

// Kategorileri kullanıcı dostu etiketlere çeviren fonksiyon
String categoryLabel(CategoryFilterOption c) {
  switch (c) {
    case CategoryFilterOption.all:
      return "Tümü";
    case CategoryFilterOption.food:
      return "Yemek";
    case CategoryFilterOption.bakery:
      return "Fırın & Pastane";
    case CategoryFilterOption.breakfast:
      return "Kahvaltı";
    case CategoryFilterOption.market:
      return "Market & Manav";
    case CategoryFilterOption.vegetarian:
      return "Vejetaryen";
    case CategoryFilterOption.vegan:
      return "Vegan";
    case CategoryFilterOption.glutenFree:
      return "Glutensiz";
  }
}

// Kategori Filtre Butonu için kullanılan Widget
class CategoryFilterOptionWidget extends StatelessWidget {
  final CategoryFilterOption category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterOptionWidget({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.primaryDarkGreen.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            Text(
              categoryLabel(category),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}