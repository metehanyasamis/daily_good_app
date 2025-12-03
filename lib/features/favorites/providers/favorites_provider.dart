// lib/features/favorites/providers/favorites_provider.dart

import 'package:flutter/foundation.dart'; // debugPrint için
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../../businessShop/data/model/businessShop_model.dart';
import '../../product/data/models/product_model.dart';
import '../data/repository/favorite_repository.dart';

// ... (favoriteRepositoryProvider aynı kaldı) ...
final favoriteRepositoryProvider = Provider((ref) {
  return FavoriteRepository(ref.watch(dioProvider));
});


// --- STATE NOTIFIER VE BUSINESS LOGIC ---

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final repo = ref.watch(favoriteRepositoryProvider);
  return FavoritesNotifier(repo);
});

class FavoritesState {
  final List<ProductModel> favoriteProducts; // ✅ ARTIK API'DEN GELİYOR
  final List<BusinessModel> favoriteShops;   // ✅ API'DEN GELİYOR

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
  final FavoriteRepository _repository;

  FavoritesNotifier(this._repository) : super(FavoritesState()) {
    fetchFavoriteShops();
    fetchFavoriteProducts(); // 💚 Yeni: Başlangıçta favori ürünleri de çek
  }

  /// 🌐 API'den favori işletmeleri çeker (Mevcut metot)
  Future<void> fetchFavoriteShops() async {
    // ... (kod aynı kaldı) ...
    debugPrint('🔄 Favori İşletme listesi yükleniyor...');
    try {
      final shops = await _repository.getFavoriteShops();
      state = state.copyWith(favoriteShops: shops);
      debugPrint('✅ Favori İşletme listesi güncellendi. Toplam: ${shops.length}');
    } catch (e) {
      debugPrint('❌ Favori İşletmeleri yükleme hatası: $e');
    }
  }

  /// 🌐 API'den favori ürünleri çeker (Yeni metot)
  Future<void> fetchFavoriteProducts() async {
    debugPrint('🔄 Favori Ürün listesi yükleniyor...');
    try {
      final products = await _repository.getFavoriteProducts();
      state = state.copyWith(favoriteProducts: products);
      debugPrint('✅ Favori Ürün listesi güncellendi. Toplam: ${products.length}');
    } catch (e) {
      debugPrint('❌ Favori Ürünleri yükleme hatası: $e');
    }
  }

  // ----------------------------------------------------
  // ⭐️ İŞLETME FAVORİ İŞLEMLERİ (Aynı kaldı)
  // ----------------------------------------------------

  /// 🔹 İşletme favori ekleme/çıkarma (API'yi çağırır)
  Future<void> toggleShop(BusinessModel shop) async {
    final isFav = isShopFav(shop);
    debugPrint('Toggle Shop: ID ${shop.id}, Mevcut Durum: ${isFav ? 'Favoride' : 'Favoride değil'}');

    try {
      final success = isFav
          ? await _repository.removeFavoriteShop(shop.id)
          : await _repository.addFavoriteShop(shop.id);

      if (success) {
        if (isFav) {
          state = state.copyWith(
            favoriteShops: state.favoriteShops.where((s) => s.id != shop.id).toList(),
          );
          debugPrint('➖ İşletme (${shop.id}) başarıyla favorilerden kaldırıldı (Lokal State).');
        } else {
          final newShop = shop.copyWith(isFavorite: true);
          state = state.copyWith(
            favoriteShops: [...state.favoriteShops, newShop],
          );
          debugPrint('➕ İşletme (${shop.id}) başarıyla favorilere eklendi (Lokal State).');
        }
      } else {
        debugPrint('❗ API işlemi başarılı dönmedi, State güncellenmedi.');
      }
    } catch (e) {
      debugPrint('❌ toggleShop HATA: İşletme favori güncellenemedi: $e');
    }
  }

  bool isShopFav(BusinessModel shop) =>
      state.favoriteShops.any((s) => s.id == shop.id);

  // ----------------------------------------------------
  // 💚 ÜRÜN FAVORİ İŞLEMLERİ (API Entegre Edildi)
  // ----------------------------------------------------

  /// 🔹 Ürün favori ekleme/çıkarma (API'yi çağırır)
  Future<void> toggleProduct(ProductModel product) async {
    final isFav = isProductFav(product);
    debugPrint('Toggle Product: ID ${product.id}, Mevcut Durum: ${isFav ? 'Favoride' : 'Favoride değil'}');

    try {
      final success = isFav
          ? await _repository.removeFavoriteProduct(product.id)
          : await _repository.addFavoriteProduct(product.id);

      if (success) {
        // API başarılı yanıt verdi, State'i yerel olarak güncelle
        if (isFav) {
          state = state.copyWith(
            favoriteProducts: state.favoriteProducts.where((p) => p.id != product.id).toList(),
          );
          debugPrint('➖ Ürün (${product.id}) başarıyla favorilerden kaldırıldı (Lokal State).');
        } else {
          // Favoriye eklenen ProductModel'ın isFavorite alanı güncellenmeli.
          final newProduct = product.copyWith(isFavorite: true);
          state = state.copyWith(
            favoriteProducts: [...state.favoriteProducts, newProduct],
          );
          debugPrint('➕ Ürün (${product.id}) başarıyla favorilere eklendi (Lokal State).');
        }
      } else {
        debugPrint('❗ API işlemi başarılı dönmedi, State güncellenmedi.');
      }
    } catch (e) {
      debugPrint('❌ toggleProduct HATA: Ürün favori güncellenemedi: $e');
    }
  }

  bool isProductFav(ProductModel product) =>
      state.favoriteProducts.any((p) => p.id == product.id);
}