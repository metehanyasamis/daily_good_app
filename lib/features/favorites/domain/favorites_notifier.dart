import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../product/data/models/product_model.dart';
import '../../product/data/repository/product_repository.dart';
import '../../product/domain/products_notifier.dart';
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
  final repo = ref.read(favoriteRepositoryProvider);
  return FavoritesNotifier(repo, ref);
});

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final FavoriteRepository repo;
  final Ref ref;

  FavoritesNotifier(this.repo, this.ref) : super(const FavoritesState());

  /// Tüm favorileri backend ile senkronize eder ve eksik verileri tamamlar.
  Future<void> loadAll() async {
    debugPrint('📡 [FAV_ROOT] loadAll() tetiklendi...');
    //state = state.copyWith(isLoading: true);

    try {
      // 1. API'den verileri çek
      final favProducts = await repo.fetchFavoriteProducts();
      final favStores = await repo.fetchFavoriteStores();

      debugPrint('📊 [FAV_DATA] API Gelen Sayılar -> Ürün: ${favProducts.length}, Mağaza: ${favStores.length}');

      // 2. RAM'deki ana listeyi oku
      final allProducts = ref.read(productsProvider).products;
      debugPrint('🔎 [FAV_RAM] RAMdeki Ürün Sayısı: ${allProducts.length}');

      List<ProductModel> enrichedProducts = [];

      // 3. Ürünleri Tek Tek Analiz Et
      for (int i = 0; i < favProducts.length; i++) {
        final favItem = favProducts[i];
        debugPrint('--- [FAV_ITEM #$i] Analiz Başladı ---');
        debugPrint('🆔 productId (API): ${favItem.productId}');

        // toDomain() öncesi ham ürün ismini kontrol et
        debugPrint('📦 Ham Ürün Adı: ${favItem.product.name}');
        debugPrint('🏠 Ham Mağaza Bilgisi: ${favItem.product.store?.name ?? "NULL!"}');

        final domainModel = favItem.toDomain();

        // EŞLEŞTİRME TESTİ
        final match = allProducts.where((p) => p.id.toString() == domainModel.id.toString()).toList();

        if (match.isNotEmpty) {
          debugPrint('✅ [MATCH] RAMde bulundu: ${match.first.name} (ID: ${match.first.id})');
          enrichedProducts.add(match.first);
        } else {
          debugPrint('⚠️ [NO_MATCH] RAMde yok! ID: ${domainModel.id}. API detayına gidiliyor...');
          try {
            final detail = await ref.read(productRepositoryProvider).getProductDetail(domainModel.id);
            debugPrint('🎯 [FIXED] Detay API ile kurtarıldı: ${detail.name}');
            enrichedProducts.add(detail);
          } catch (e) {
            debugPrint('❌ [FATAL_ITEM] Detay da çekilemedi. Veri Hatası kaçınılmaz: $e');
            enrichedProducts.add(domainModel);
          }
        }
      }

      // --- 4. MAĞAZALARI ANALİZ ET (YENİLENMİŞ GARANTİ VERSİYON) ---
      final List<StoreSummary> finalEnrichedStores = [];
      final Set<String> validStoreIds = {};

      // API'den (eğer gelirse) gelen mağazaları işle
      for (var favItem in favStores) {
        if (favItem.storeId.isNotEmpty) {
          validStoreIds.add(favItem.storeId.toLowerCase().trim());
        }
        if (favItem.store != null) {
          finalEnrichedStores.add(favItem.store!);
          validStoreIds.add(favItem.store!.id.toLowerCase().trim());
        }
      }

      // 💡 YAMA: Favori ürünlerin bağlı olduğu dükkanları LİSTEYE de ekle
      for (var p in enrichedProducts) {
        final String sId = p.store.id.toLowerCase().trim();

        // Eğer bu dükkan zaten listede yoksa (API'den gelmemişse) listeye ekle
        bool alreadyInList = finalEnrichedStores.any((s) => s.id.toLowerCase().trim() == sId);

        if (!alreadyInList) {
          finalEnrichedStores.add(p.store);
          validStoreIds.add(sId);
          debugPrint('📦 [YAMA_LIST] Favori ekranı için dükkan eklendi: ${p.store.name}');
        }
      }

      state = state.copyWith(
        products: enrichedProducts,
        stores: finalEnrichedStores, // 🎯 BURASI ARTIK DOLU!
        productIds: enrichedProducts.map((e) => e.id.toLowerCase().trim()).toSet(),
        storeIds: validStoreIds,
        isLoading: false,
      );

      debugPrint('🏁 [FAV_ROOT] BİTTİ. State Store ID Seti: ${state.storeIds}');
      debugPrint('🏁 [FAV_ROOT] State Store ID Seti: ${state.storeIds}');

    } catch (e, stack) {
      debugPrint("🚨 [CRITICAL_FAV_ERROR]: $e");
      debugPrint(stack.toString());
      state = state.copyWith(isLoading: false);
    }
  }

  /// Ürün Favori İşlemi
  Future<void> toggleProduct(String id) async {
    final isFav = state.productIds.contains(id);
    final oldState = state;

    _updateProductLocal(id, !isFav);

    try {
      isFav
          ? await repo.removeFavoriteProduct(id)
          : await repo.addFavoriteProduct(id);

      await loadAll();
    } catch (e) {
      debugPrint("⚠️ [TOGGLE_PRODUCT_ERROR]: $e");
      state = oldState;
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