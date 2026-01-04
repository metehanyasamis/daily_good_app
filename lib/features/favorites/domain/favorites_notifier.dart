import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../location/domain/address_notifier.dart';
import '../../product/data/models/product_model.dart';
import '../../stores/data/model/store_summary.dart';
import '../../stores/data/repository/store_repository.dart';
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
  return FavoritesNotifier(
    repo: ref.watch(favoriteRepositoryProvider),
    storeRepo: ref.watch(storeRepositoryProvider), // 👈 Bunu eklemeyi unutma
    ref: ref,
  );
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteRepository repo;
  final StoreRepository storeRepo; // 1. Bunu ekledik
  final Ref ref; // 2. Konum bilgisini okumak için ref lazım

  FavoritesNotifier({
    required this.repo,
    required this.storeRepo,
    required this.ref,
  }) : super(const FavoritesState());


  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);

    try {
      final addressState = ref.read(addressProvider);

      // 1. Üç veriyi paralel çekiyoruz
      final List<dynamic> results = await Future.wait([
        repo.fetchFavoriteProducts(),
        repo.fetchFavoriteStores(),
        storeRepo.getStoresByLocation(
          latitude: addressState.lat,
          longitude: addressState.lng,
          perPage: 100,
        ),
      ]);

      // 🔥 HATANIN ÇÖZÜMÜ: 'as' kullanarak türleri zorluyoruz
      final List<dynamic> favProductsRaw = results[0] as List<dynamic>;
      final List<dynamic> favStoresRaw = results[1] as List<dynamic>;
      final List<StoreSummary> feedStores = results[2] as List<StoreSummary>;

      final List<ProductModel> enrichedProducts = [];
      final List<StoreSummary> finalStores = [];
      final Set<String> productIds = {};
      final Set<String> storeIds = {};

      // 2. MAĞAZALARI İŞLE (İşletme sekmesi için)
      for (var item in favStoresRaw) {
        if (item.store != null) {
          final sid = item.store!.id.toString().toLowerCase();
          storeIds.add(sid);
          finalStores.add(item.store!);
        }
      }

      // 3. ÜRÜNLERİ İŞLE VE BESLE (Mesafe/Puan için)
      for (var item in favProductsRaw) {
        if (item.product != null) {
          ProductModel pModel = item.toDomain();

          // Genel havuzdan (results[2]) dükkan verisini çekip puan/mesafe dolduruyoruz
          final matchingStore = feedStores.firstWhere(
                (s) => s.id == pModel.store.id,
            orElse: () => pModel.store,
          );

          final enriched = pModel.copyWith(
            store: matchingStore,
            rating: matchingStore.overallRating ?? 0.0,
          );

          enrichedProducts.add(enriched);
          productIds.add(enriched.id.toString().toLowerCase());
        }
      }

      // 4. STATE GÜNCELLE
      state = state.copyWith(
        products: enrichedProducts,
        stores: finalStores, // Artık boş değil, fava ekleme çalışacak
        productIds: productIds,
        storeIds: storeIds,  // Butonların rengi (kırmızı) buradan geliyor
        isLoading: false,
      );

      debugPrint('✅ [FAV_OK] Ürünler beslendi, Mağazalar yüklendi.');

    } catch (e) {
      debugPrint('🚨 [FAV_ERR] $e');
      state = state.copyWith(isLoading: false);
    }
  }



  /// Ürün Favori İşlemi
  Future<void> toggleProduct(String id) async {
    // 1. ADIM: ID'yi FavButton'ın aradığı formata getir (Küçük harf + Temiz)
    final cleanId = id.trim().toLowerCase();

    final isFav = state.productIds.contains(cleanId);
    final oldState = state;

    debugPrint('⚡ [FAV_TOGGLE] İşlem: ${isFav ? "Kaldır" : "Ekle"} | ID: $cleanId');

    // 2. ADIM: Yerel state'i anında güncelle (Optimistic Update)
    // Kullanıcı beklemesin, kalp anında dolsun/boşalsın
    if (isFav) {
      state = state.copyWith(
        productIds: state.productIds.where((i) => i != cleanId).toSet(),
      );
    } else {
      state = state.copyWith(
        productIds: {...state.productIds, cleanId},
      );
    }

    try {
      // 3. ADIM: API isteğini at
      final success = isFav
          ? await repo.removeFavoriteProduct(cleanId)
          : await repo.addFavoriteProduct(cleanId);

      if (!success) {
        // API başarısızsa eski haline geri dön
        debugPrint("❌ [TOGGLE_PRODUCT] API başarısız döndü, geri alınıyor.");
        state = oldState;
      }

      // 4. ADIM: Her durumda loadAll() çağırarak backend ile eşleş
      // Ama loadAll() içindeki toLowerCase() düzeltmesini yapmış olman lazım!
      await loadAll();

    } catch (e) {
      debugPrint("⚠️ [TOGGLE_PRODUCT_ERROR]: $e");
      state = oldState; // Hata anında kalbi eski durumuna çek
      await loadAll();
    }
  }

  /// İşletme Favori İşlemi
  Future<void> toggleStore(String id) async {
    final isFav = state.storeIds.contains(id);
    final oldState = state; // Yapıyı bozmamak için oldState'i saklıyoruz

    _updateStoreLocal(id, !isFav);

    try {
      final success = isFav
          ? await repo.removeFavoriteStore(id)
          : await repo.addFavoriteStore(id);

      if (!success) throw "API hatası";

      await Future.delayed(const Duration(milliseconds: 1000));
      await loadAll();
    } catch (e) {
      debugPrint("🚨 [TOGGLE_STORE_ERROR] Geri alınıyor: $e");
      state = oldState; // 🎯 Hata (gerçekten bağlantı kopması vs) olursa geri al
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
    final normalizedId = id.toLowerCase(); // 🎯 Standartlaştır
    if (add) newIds.add(normalizedId); else newIds.remove(normalizedId);
    state = state.copyWith(storeIds: newIds);
  }

  void clear() {
    state = const FavoritesState();
  }
}