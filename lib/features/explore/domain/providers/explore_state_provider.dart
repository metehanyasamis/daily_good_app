// lib/features/explore/domain/providers/explore_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/widgets/category_filter_option.dart';
import '../../presentation/widgets/explore_filter_sheet.dart';

class ExploreState {
  final ExploreFilterOption sort;
  final CategoryFilterOption category;

  const ExploreState({
    this.sort = ExploreFilterOption.recommended,
    this.category = CategoryFilterOption.all,
  });

  ExploreState copyWith({
    ExploreFilterOption? sort,
    CategoryFilterOption? category,
  }) {
    return ExploreState(
      sort: sort ?? this.sort,
      category: category ?? this.category,
    );
  }
}

class ExploreStateNotifier extends StateNotifier<ExploreState> {
  ExploreStateNotifier() : super(const ExploreState());

  void setSort(ExploreFilterOption value) {
    state = state.copyWith(sort: value);
  }

  void setCategory(CategoryFilterOption value) {
    state = state.copyWith(category: value);
  }
}

final exploreStateProvider =
StateNotifierProvider<ExploreStateNotifier, ExploreState>(
      (ref) => ExploreStateNotifier(),
);
