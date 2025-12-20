import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository/category_repository.dart';
import '../data/repository/category_repository_provider.dart';
import 'category_state.dart';

final categoryProvider =
StateNotifierProvider<CategoryNotifier, CategoryState>((ref) {
  return CategoryNotifier(ref.read(categoryRepositoryProvider));
});

class CategoryNotifier extends StateNotifier<CategoryState> {
  final CategoryRepository repo;

  CategoryNotifier(this.repo) : super(const CategoryState());

  Future<void> load() async {
    debugPrint("🟡 [CATEGORY] load başladı");
    state = state.copyWith(isLoading: true);

    try {
      final list = await repo.fetchCategories();

      // 🔥 ASC SIRALAMA (id’ye göre)
      list.sort((a, b) => a.id.compareTo(b.id));

      debugPrint("🟢 [CATEGORY] gelen kategori sayısı = ${list.length}");

      state = state.copyWith(
        isLoading: false,
        categories: list,
      );
    } catch (e, s) {
      debugPrint("🔴 [CATEGORY] ERROR → $e");
      debugPrint(s.toString());

      state = state.copyWith(isLoading: false);
    }
  }

}
