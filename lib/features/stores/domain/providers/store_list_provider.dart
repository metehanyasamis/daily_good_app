import 'package:daily_good/features/stores/domain/providers/store_detail_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/store_detail_model.dart';
import '../../data/repository/store_repository.dart';
import '../../../../core/providers/dio_provider.dart';

class StoreListState {
  final List<StoreDetailModel> stores;
  final bool loading;
  final String? error;

  StoreListState({
    this.stores = const [],
    this.loading = false,
    this.error,
  });

  StoreListState copyWith({
    List<StoreDetailModel>? stores,
    bool? loading,
    String? error,
  }) {
    return StoreListState(
      stores: stores ?? this.stores,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

final storeListProvider =
StateNotifierProvider<StoreListNotifier, StoreListState>((ref) {
  return StoreListNotifier(ref.watch(storeRepositoryProvider));
});

class StoreListNotifier extends StateNotifier<StoreListState> {
  final StoreRepository _repo;

  StoreListNotifier(this._repo) : super(StoreListState(loading: true)) {
    fetchStores();
  }

  /// Backend'de: GET /stores
  Future<void> fetchStores() async {
    try {
      state = state.copyWith(loading: true);

      final stores = await _repo.getStores(); // repository içinde yazacağız.

      state = state.copyWith(stores: stores, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
