import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../businessShop/data/model/businessShop_model.dart';
import '../../product/data/models/product_model.dart';


final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier();
});

class FavoritesState {
  final List<ProductModel> favoriteProducts;
  final List<BusinessModel> favoriteShops;

  FavoritesState({
    this.favoriteProducts = const [],
    this.favoriteShops = const [],
  });

  FavoritesState copyWith({
    List<ProductModel>? favoriteProducts,
    List<BusinessModel>? favoriteShops,
  }) {
    return FavoritesState(
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      favoriteShops: favoriteShops ?? this.favoriteShops,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  FavoritesNotifier() : super(FavoritesState());

  // 🔹 Ürün favori ekleme/çıkarma
  void toggleProduct(ProductModel product) {
    final isFav = state.favoriteProducts.contains(product);
    if (isFav) {
      state = state.copyWith(
        favoriteProducts: state.favoriteProducts.where((p) => p != product).toList(),
      );
    } else {
      state = state.copyWith(
        favoriteProducts: [...state.favoriteProducts, product],
      );
    }
  }

  // 🔹 İşletme favori ekleme/çıkarma
  void toggleShop(BusinessModel shop) {
    final isFav = state.favoriteShops.contains(shop);
    if (isFav) {
      state = state.copyWith(
        favoriteShops: state.favoriteShops.where((s) => s != shop).toList(),
      );
    } else {
      state = state.copyWith(
        favoriteShops: [...state.favoriteShops, shop],
      );
    }
  }

  bool isProductFav(ProductModel product) =>
      state.favoriteProducts.contains(product);

  bool isShopFav(BusinessModel shop) =>
      state.favoriteShops.contains(shop);
}
