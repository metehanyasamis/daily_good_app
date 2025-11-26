import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/home_state.dart';

class HomeStateNotifier extends StateNotifier<HomeState> {
  HomeStateNotifier()
      : super(const HomeState(
    selectedAddress: 'Nail Bey Sok.',
    selectedCategoryIndex: 0,
    hasActiveOrder: false,
  ));

  void setAddress(String value) {
    state = state.copyWith(selectedAddress: value);
  }

  void setCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void setHasActiveOrder(bool value) {
    state = state.copyWith(hasActiveOrder: value);
  }
}

final homeStateProvider =
StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  return HomeStateNotifier();
});
