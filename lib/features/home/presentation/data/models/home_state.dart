import 'package:equatable/equatable.dart';
import '../../../../product/data/models/product_model.dart';

enum HomeSection {
  hemenYaninda,
  sonSans,
  yeni,
  bugun,
  yarin,
}

class HomeState extends Equatable {
  final int selectedCategoryIndex;
  final bool hasActiveOrder;

  /// 🔥 Section bazlı ürünler
  final Map<HomeSection, List<ProductModel>> sectionProducts;

  /// 🔄 Section loading
  final Map<HomeSection, bool> loadingSections;

  const HomeState({
    required this.selectedCategoryIndex,
    required this.hasActiveOrder,
    required this.sectionProducts,
    required this.loadingSections,
  });

  factory HomeState.initial() {
    return HomeState(
      selectedCategoryIndex: 0,
      hasActiveOrder: false,
      sectionProducts: {
        for (var s in HomeSection.values) s: const [],
      },
      loadingSections: {
        for (var s in HomeSection.values) s: false,
      },
    );
  }

  HomeState copyWith({
    int? selectedCategoryIndex,
    bool? hasActiveOrder,
    Map<HomeSection, List<ProductModel>>? sectionProducts,
    Map<HomeSection, bool>? loadingSections,
  }) {
    return HomeState(
      selectedCategoryIndex:
      selectedCategoryIndex ?? this.selectedCategoryIndex,
      hasActiveOrder: hasActiveOrder ?? this.hasActiveOrder,
      sectionProducts: sectionProducts ?? this.sectionProducts,
      loadingSections: loadingSections ?? this.loadingSections,
    );
  }

  @override
  List<Object?> get props => [
    selectedCategoryIndex,
    hasActiveOrder,
    sectionProducts,
    loadingSections,
  ];
}
