import '../data/models/category_model.dart';

class CategoryState {
  final bool isLoading;
  final List<CategoryModel> categories;

  const CategoryState({
    this.isLoading = false,
    this.categories = const [],
  });

  CategoryState copyWith({
    bool? isLoading,
    List<CategoryModel>? categories,
  }) {
    return CategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
    );
  }
}
