import '../../explore/presentation/widgets/category_filter_option.dart';

class CarbonRules {
  /// Kategori bazlı CO₂ tahmin (kg)
  static const Map<CategoryFilterOption, double> categoryCarbon = {
    CategoryFilterOption.food: 0.40,         // Yemek
    CategoryFilterOption.bakery: 0.20,       // Fırın & Pastane
    CategoryFilterOption.breakfast: 0.30,    // Kahvaltı
    CategoryFilterOption.market: 0.25,       // Market & Manav
    CategoryFilterOption.vegetarian: 0.28,   // Vejetaryen
    CategoryFilterOption.vegan: 0.22,        // Vegan
    CategoryFilterOption.glutenFree: 0.26,   // Glutensiz

    // Tümü kategorisi (filtre için kullanılıyor, CO₂ hesabında kullanılmayacak)
    CategoryFilterOption.all: 0.30,
  };

  /// CO₂ hesaplama
  static double getCarbon(CategoryFilterOption category) {
    return categoryCarbon[category] ?? 0.30;
  }
}
