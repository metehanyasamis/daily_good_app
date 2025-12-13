import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/models/product_model.dart';
import '../../stores/data/model/store_summary.dart';
import '../data/repository/favorite_repository.dart';

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.read(favoriteRepositoryProvider));
});

class FavoritesState {
  final Set<String> productIds;
  final Set<String> storeIds;
  final List<ProductModel> products;
  final List<StoreSummary> stores;
  final bool isLoading;

  const FavoritesState({
    this.productIds = const {},
    this.storeIds = const {},
    this.products = const [],
    this.stores = const [],
    this.isLoading = false,
  });

  FavoritesState copyWith({
    Set<String>? productIds,
    Set<String>? storeIds,
    List<ProductModel>? products,
    List<StoreSummary>? stores,
    bool? isLoading,
  }) {
    return FavoritesState(
      productIds: productIds ?? this.productIds,
      storeIds: storeIds ?? this.storeIds,
      products: products ?? this.products,
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteRepository repo;
  FavoritesNotifier(this.repo) : super(const FavoritesState());

  // ---------- INIT ----------
  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);

    final products = await repo.fetchFavoriteProducts();
    final stores = await repo.fetchFavoriteStores();

    state = state.copyWith(
      products: products.map((e) => e.toDomain()).toList(),
      stores: stores.map((e) => e.store).toList(),
      productIds: products.map((e) => e.productId).toSet(),
      storeIds: stores.map((e) => e.store.id).toSet(),
      isLoading: false,
    );
  }

  // ---------- TOGGLE PRODUCT ----------
  Future<void> toggleProduct(String id) async {
    final isFav = state.productIds.contains(id);
    final newSet = {...state.productIds};

    isFav ? newSet.remove(id) : newSet.add(id);
    state = state.copyWith(productIds: newSet);

    try {
      isFav
          ? await repo.removeFavoriteProduct(id)
          : await repo.addFavoriteProduct(id);
    } catch (_) {
      // rollback
      state = state.copyWith(productIds: state.productIds);
    }
  }

  // ---------- TOGGLE STORE ----------
  Future<void> toggleStore(String id) async {
    final isFav = state.storeIds.contains(id);
    final newSet = {...state.storeIds};

    isFav ? newSet.remove(id) : newSet.add(id);
    state = state.copyWith(storeIds: newSet);

    try {
      isFav
          ? await repo.removeFavoriteStore(id)
          : await repo.addFavoriteStore(id);
    } catch (_) {
      state = state.copyWith(storeIds: state.storeIds);
    }
  }
}
