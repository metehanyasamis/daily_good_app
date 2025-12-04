import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/models/product_model.dart';
import '../../product/data/models/store_summary.dart';
import '../data/repository/favorite_repository.dart';


final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.read(favoriteRepositoryProvider));
});

class FavoritesState {
  final List<ProductModel> favoriteProducts;
  final List<StoreSummary> favoriteShops;
  final bool isLoading;

  FavoritesState({
    this.favoriteProducts = const [],
    this.favoriteShops = const [],
    this.isLoading = false,
  });

  FavoritesState copyWith({
    List<ProductModel>? favoriteProducts,
    List<StoreSummary>? favoriteShops,
    bool? isLoading,
  }) {
    return FavoritesState(
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      favoriteShops: favoriteShops ?? this.favoriteShops,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}


class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteRepository repo;

  FavoritesNotifier(this.repo) : super(FavoritesState());

  // ---------------------------
  // FAVORİ ÜRÜNLERİ ÇEK
  // ---------------------------
  Future<void> fetchFavoriteProducts() async {
    state = state.copyWith(isLoading: true);
    final res = await repo.getFavoriteProducts();
    state = state.copyWith(
      favoriteProducts: res.map((e) => e.toDomain()).toList(),
      isLoading: false,
    );
  }

  // ---------------------------
  // FAVORİ İŞLETMELERİ ÇEK
  // ---------------------------
  Future<void> fetchFavoriteStores() async {
    state = state.copyWith(isLoading: true);
    final res = await repo.getFavoriteStores();
    state = state.copyWith(
      favoriteShops: res.map((e) => e.toDomain()).toList(),
      isLoading: false,
    );
  }

  // ---------------------------
  // FAVORİ ÜRÜN TOGGLE
  // ---------------------------
  Future<void> toggleProductFavorite(String id) async {
    final existing = state.favoriteProducts.any((p) => p.id == id);

    if (existing) {
      await repo.removeFavoriteProduct(id);
    } else {
      await repo.addFavoriteProduct(id);
    }

    await fetchFavoriteProducts();
  }

  // ---------------------------
  // FAVORİ STORE TOGGLE
  // ---------------------------
  Future<void> toggleStoreFavorite(String id) async {
    final existing = state.favoriteShops.any((s) => s.id == id);

    if (existing) {
      await repo.removeFavoriteStore(id);
    } else {
      await repo.addFavoriteStore(id);
    }

    await fetchFavoriteStores();
  }
}
