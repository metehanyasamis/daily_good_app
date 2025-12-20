// lib/features/explore/domain/providers/explore_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/explore_filter_sheet.dart';

class ExploreState {
  final ExploreFilterOption sort;
  final String? categoryId; // 🔥 enum değil

  const ExploreState({
    this.sort = ExploreFilterOption.recommended,
    this.categoryId,
  });

  ExploreState copyWith({
    ExploreFilterOption? sort,
    String? categoryId,
  }) {
    return ExploreState(
      sort: sort ?? this.sort,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}


class ExploreStateNotifier extends StateNotifier<ExploreState> {
  ExploreStateNotifier() : super(const ExploreState());

  void setSort(ExploreFilterOption value) {
    state = state.copyWith(sort: value);
  }

  void setCategoryId(String? id) {
    state = state.copyWith(categoryId: id);
  }

}

final exploreStateProvider =
StateNotifierProvider<ExploreStateNotifier, ExploreState>(
      (ref) => ExploreStateNotifier(),
);
