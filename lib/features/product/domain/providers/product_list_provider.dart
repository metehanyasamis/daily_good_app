import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/models/product_model.dart';
import '../../data/repository/product_repository.dart';

// --- STATE MODELİ ---

class ProductListState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isFetchingMore; // Sonsuz kaydırma için
  final PaginationMeta? meta;
  final String? error;

  const ProductListState({
    this.products = const [],
    this.isLoading = false,
    this.isFetchingMore = false,
    this.meta,
    this.error,
  });

  ProductListState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isFetchingMore,
    PaginationMeta? meta,
    String? error,
    bool clearError = false,
  }) {
    return ProductListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      meta: meta ?? this.meta,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// --- API KATMANI PROVIDER'I ---
final productRepositoryProvider = Provider((ref) {
  return ProductRepository(ref.watch(dioProvider));
});


// --- STATE NOTIFIER VE BUSINESS LOGIC ---

class ProductListController extends StateNotifier<ProductListState> {
  final ProductRepository _repository;

  ProductListController(this._repository) : super(const ProductListState());

  bool get hasMore => state.meta == null || state.meta!.currentPage < state.meta!.lastPage;

  // 🔥 Parametreleri tutmak için bir Map kullanıyoruz
  Map<String, dynamic> _currentParams = {};

  // ------------------------------------------
  // Ürün Listesi Çekme
  // ------------------------------------------

  /// 🌐 Ürün listesini filtreler ve çeker (Sayfa 1'den başlar)
  Future<void> fetchProducts({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? name,
    String? sortBy,
    String? sortOrder,
    bool hemenYaninda = false,
    bool sonSans = false,
    bool yeni = false,
    bool bugun = false,
    bool yarin = false,
  }) async {
    // Yeni parametreleri kaydet
    _currentParams = {
      'categoryId': categoryId, 'latitude': latitude, 'longitude': longitude,
      'name': name, 'sortBy': sortBy, 'sortOrder': sortOrder,
      'hemenYaninda': hemenYaninda, 'sonSans': sonSans, 'yeni': yeni,
      'bugun': bugun, 'yarin': yarin
    };

    state = state.copyWith(isLoading: true, products: [], meta: null, clearError: true);

    try {
      final result = await _repository.fetchProducts(
        page: 1, // Her zaman 1. sayfadan başlar
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        // 🔥 Repository'de hata veren parametreler burada kullanılıyor.
        name: name,
        sortBy: sortBy,
        sortOrder: sortOrder,
        hemenYaninda: hemenYaninda,
        sonSans: sonSans,
        yeni: yeni,
        bugun: bugun,
        yarin: yarin,
      );

      state = state.copyWith(
        products: result.products,
        meta: result.meta,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ Ürün listesi çekme hatası: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 🔄 Sonraki sayfayı çeker (Sonsuz kaydırma)
  Future<void> fetchMoreProducts() async {
    if (state.isLoading || state.isFetchingMore || !hasMore) {
      return;
    }

    final nextPage = state.meta!.currentPage + 1;
    debugPrint('➡️ Sonraki sayfa çekiliyor: $nextPage');

    state = state.copyWith(isFetchingMore: true, clearError: true);

    try {
      final result = await _repository.fetchProducts(
        page: nextPage,
        // Kaydedilmiş parametreleri güvenli bir şekilde çek
        categoryId: _currentParams['categoryId'] as String?,
        latitude: _currentParams['latitude'] as double?,
        longitude: _currentParams['longitude'] as double?,
        name: _currentParams['name'] as String?,
        sortBy: _currentParams['sortBy'] as String?,
        sortOrder: _currentParams['sortOrder'] as String?,
        hemenYaninda: _currentParams['hemenYaninda'] as bool? ?? false,
        sonSans: _currentParams['sonSans'] as bool? ?? false,
        yeni: _currentParams['yeni'] as bool? ?? false,
        bugun: _currentParams['bugun'] as bool? ?? false,
        yarin: _currentParams['yarin'] as bool? ?? false,
      );

      state = state.copyWith(
        products: [...state.products, ...result.products],
        meta: result.meta,
        isFetchingMore: false,
      );
    } catch (e) {
      debugPrint('❌ Sonraki sayfa çekme hatası: $e');
      state = state.copyWith(isFetchingMore: false, error: e.toString());
    }
  }
}

final productListControllerProvider = StateNotifierProvider<ProductListController, ProductListState>(
      (ref) => ProductListController(ref.watch(productRepositoryProvider)),
);


// ------------------------------------------
// Ürün Detay Provider'ı
// ------------------------------------------

/// 🌐 Belirli bir ürün detayını çeken FutureProvider
final productDetailProvider = FutureProvider.family<ProductModel, String>((ref, productId) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProductDetail(productId);
});