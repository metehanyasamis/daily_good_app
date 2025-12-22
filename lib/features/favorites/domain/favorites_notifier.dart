import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/models/product_model.dart';
import '../../stores/data/model/store_summary.dart';
import '../data/repository/favorite_repository.dart';

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

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(ref.read(favoriteRepositoryProvider));
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteRepository repo;
  FavoritesNotifier(this.repo) : super(const FavoritesState());

  /// Tüm favorileri backend ile senkronize eder.
  Future<void> loadAll() async {
    debugPrint('📡 [FAV_SERVICE] Favoriler çekiliyor...');
    try {
      final favProducts = await repo.fetchFavoriteProducts();
      debugPrint('📦 [FAV_SERVICE] Gelen Ürün Ham Veri: ${favProducts.length}');

      final favStores = await repo.fetchFavoriteStores();

      final pIds = favProducts.map((e) => e.productId).toSet();
      final sIds = favStores.map((e) => e.store.id).toSet();

      debugPrint('🔄 [FAV_SYNC] Ürün: ${pIds.length}, Mağaza: ${sIds.length}');

      state = state.copyWith(
        products: favProducts.map((e) => e.toDomain()).toList(),
        stores: favStores.map((e) => e.store).toList(),
        productIds: pIds,
        storeIds: sIds,
        isLoading: false,
      );
    } catch (e) {
      debugPrint("❌ [FAV_SYNC_ERROR]: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  /// Ürün Favori İşlemi
  Future<void> toggleProduct(String id) async {
    final isFav = state.productIds.contains(id);
    final oldState = state;

    // 1. Optimistic Update (Hız hissi için UI'ı hemen güncelle)
    _updateProductLocal(id, !isFav);

    try {
      final bool success = isFav
          ? await repo.removeFavoriteProduct(id)
          : await repo.addFavoriteProduct(id);

      // Backend 400 dönse bile (zaten favori durumu), loadAll ile durumu netleştiriyoruz.
      // Eğer repo içinde 400 hatası catch edilip false dönüyorsa burası çalışır.
      await loadAll();

    } catch (e) {
      debugPrint("⚠️ [TOGGLE_PRODUCT_ERROR] ID: $id - Hata: $e");
      // Hata gerçekten kritikse (örn: internet yoksa) eski haline dön
      state = oldState;
      // Ama her ihtimale karşı listeyi bir kez daha çekmeye çalış
      await loadAll();
    }
  }

  /// İşletme Favori İşlemi
  Future<void> toggleStore(String id) async {
    final isFav = state.storeIds.contains(id);
    final oldState = state;

    _updateStoreLocal(id, !isFav);

    try {
      final bool success = isFav
          ? await repo.removeFavoriteStore(id)
          : await repo.addFavoriteStore(id);

      await loadAll();
    } catch (e) {
      debugPrint("⚠️ [TOGGLE_STORE_ERROR] ID: $id - Hata: $e");
      state = oldState;
      await loadAll();
    }
  }

  // --- Yardımcı Metodlar (Local Update) ---

  void _updateProductLocal(String id, bool add) {
    final newIds = Set<String>.from(state.productIds);
    if (add) newIds.add(id); else newIds.remove(id);
    state = state.copyWith(productIds: newIds);
  }

  void _updateStoreLocal(String id, bool add) {
    final newIds = Set<String>.from(state.storeIds);
    if (add) newIds.add(id); else newIds.remove(id);
    state = state.copyWith(storeIds: newIds);
  }

  void clear() {
    state = const FavoritesState();
  }
}