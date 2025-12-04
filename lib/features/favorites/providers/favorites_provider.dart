import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/models/product_model.dart';
import '../../product/data/models/store_summary.dart';
import '../data/repository/favorite_repository.dart';
import '../../../core/providers/dio_provider.dart';

class FavoritesState {
  final List<ProductModel> favoriteProducts;
  final List<StoreSummary> favoriteShops;
  final bool isLoading;

  const FavoritesState({
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
},

  FavoritesState copyWith({
    List<ProductModel>? favoriteProducts,
    List<StoreSummary>? favoriteStores,
  }) {
    return FavoritesState(
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      favoriteStores: favoriteStores ?? this.favoriteStores,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteRepository repo;

  FavoritesNotifier(this.repo) : super(FavoritesState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    final products = await repo.getFavoriteProducts();
    final stores = await repo.getFavoriteShops();

    state = state.copyWith(
      favoriteProducts: products,
      favoriteStores: stores,
    );
  }

  bool isProductFav(String id) =>
      state.favoriteProducts.any((p) => p.id == id);

  bool isStoreFav(String id) =>
      state.favoriteStores.any((s) => s.id == id);

  Future<void> toggleProduct(ProductModel product) async {
    if (isProductFav(product.id)) {
      await repo.removeFavoriteProduct(product.id);
      state = state.copyWith(
        favoriteProducts:
        state.favoriteProducts.where((p) => p.id != product.id).toList(),
      );
    } else {
      await repo.addFavoriteProduct(product.id);
      state = state.copyWith(
        favoriteProducts: [...state.favoriteProducts, product],
      );
    }
  }

  Future<void> toggleStore(StoreSummary store) async {
    if (isStoreFav(store.id)) {
      await repo.removeFavoriteShop(store.id);
      state = state.copyWith(
        favoriteStores:
        state.favoriteStores.where((s) => s.id != store.id).toList(),
      );
    } else {
      await repo.addFavoriteShop(store.id);
      state = state.copyWith(
        favoriteStores: [...state.favoriteStores, store],
      );
    }
  }
}
