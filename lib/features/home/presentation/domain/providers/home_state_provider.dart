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

  Future<void> loadSection(
      HomeSection section, {
        required double latitude,
        required double longitude,
      }) async {
    if (state.loadingSections[section] == true) return;

    state = state.copyWith(
      loadingSections: {
        ...state.loadingSections,
        section: true,
      },
    );

    try {
      final res = await repo.fetchProducts(
        latitude: latitude,
        longitude: longitude,
        hemenYaninda: section == HomeSection.hemenYaninda,
        sonSans: section == HomeSection.sonSans,
        yeni: section == HomeSection.yeni,
        bugun: section == HomeSection.bugun,
        yarin: section == HomeSection.yarin,
      );

      state = state.copyWith(
        sectionProducts: {
          ...state.sectionProducts,
          section: res.products,
        },
      );
    } catch (e) {
      // istersek log, snackbar vs
    } finally {
      state = state.copyWith(
        loadingSections: {
          ...state.loadingSections,
          section: false,
        },
      );
    }
  }

}

final homeStateProvider =
StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  return HomeStateNotifier(ref.read(productRepositoryProvider));
});
