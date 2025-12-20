import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../product/data/repository/product_repository.dart';
import '../../data/models/home_state.dart';


class HomeStateNotifier extends StateNotifier<HomeState> {
  final ProductRepository repo;

  HomeStateNotifier(this.repo) : super(HomeState.initial());

  void setCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void setHasActiveOrder(bool value) {
    state = state.copyWith(hasActiveOrder: value);
  }

  Future<void> loadHome({
    required double latitude,
    required double longitude,
  }) async {
    debugPrint("🏠 [HOME] loadHome");

    state = state.copyWith(
      loadingSections: {
        for (var s in HomeSection.values) s: true,
      },
    );

    final sections = await repo.fetchHomeSections(
      latitude: latitude,
      longitude: longitude,
    );

    state = state.copyWith(
      sectionProducts: sections,
      loadingSections: {
        for (var s in HomeSection.values) s: false,
      },
    );
  }
}



final homeStateProvider =
StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  return HomeStateNotifier(ref.read(productRepositoryProvider));
});
