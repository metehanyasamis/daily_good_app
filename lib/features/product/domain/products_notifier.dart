// lib/features/product/domain/products_notifier.dart

/*import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/product_repository.dart';
import 'products_state.dart';

final productsProvider =
StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(ref.read(productRepositoryProvider));
});

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository repo;
  ProductsNotifier(this.repo) : super(const ProductsState());

  Future<void> loadOnce({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    if (state.initialized || state.isLoadingList) {
      debugPrint('⛔ loadOnce SKIP (initialized=${state.initialized}, loading=${state.isLoadingList})');
      return;
    }

    await _fetchList(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      search: search,
      hemenYaninda: hemenYaninda,
      sonSans: sonSans,
      yeni: yeni,
      bugun: bugun,
      yarin: yarin,
      markInitialized: true,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<void> refresh({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    debugPrint('📡 BACKEND REFRESH → categoryId=$categoryId lat=$latitude lng=$longitude sortBy=$sortBy sortOrder=$sortOrder');

    await _fetchList(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      search: search,
      hemenYaninda: hemenYaninda,
      sonSans: sonSans,
      yeni: yeni,
      bugun: bugun,
      yarin: yarin,
      markInitialized: true,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<void> _fetchList({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    bool markInitialized = false,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    state = state.copyWith(isLoadingList: true, clearError: true);

    debugPrint('🧾 [NOTIFIER_FETCH] BEFORE CALL');
    debugPrint('   categoryId=$categoryId');
    debugPrint('   lat=$latitude lng=$longitude');
    debugPrint('   search=$search');
    debugPrint('   flags: hemen=$hemenYaninda sonSans=$sonSans yeni=$yeni bugun=$bugun yarin=$yarin');
    debugPrint('   sort=$sortBy $sortOrder');

    try {
      final parsedProducts = await repo.fetchProductsList(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        search: search,
        perPage: 15,
        page: 1,
        sortBy: sortBy,
        sortOrder: sortOrder,
        hemenYaninda: hemenYaninda,
        sonSans: sonSans,
        yeni: yeni,
        bugun: bugun,
        yarin: yarin,
      );

      debugPrint('📦 PRODUCTS COUNT = ${parsedProducts.length}');
      if (parsedProducts.isNotEmpty) {
        final p = parsedProducts.first;
        debugPrint('📦 FIRST → id=${p.id} name=${p.name} stock=${p.stock}');
      }

      state = state.copyWith(
        products: parsedProducts,
        isLoadingList: false,
        initialized: markInitialized ? true : state.initialized,
      );

      debugPrint('✅ STATE UPDATED | products=${state.products.length}');
      debugPrint('==============================================');
    } catch (e, st) {
      debugPrint('❌ FETCH ERROR → $e');
      debugPrint(st.toString());
      state = state.copyWith(
        isLoadingList: false,
        error: e.toString(),
      );
    }
  }


  // detail...
  Future<void> fetchDetail(String productId) async {
    state = state.copyWith(isLoadingDetail: true, clearError: true);

    try {
      final product = await repo.getProductDetail(productId);
      state = state.copyWith(
        selectedProduct: product,
        isLoadingDetail: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        error: e.toString(),
      );
    }
  }

  void clearDetail() {
    state = state.copyWith(clearSelectedProduct: true);
  }
}

 */

// lib/features/product/domain/products_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../location/domain/address_notifier.dart';
import '../data/repository/product_repository.dart';
import 'products_state.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  // 📍 ADRESİ İZLE: Adres değişince bu provider'ı tamamen yeniler
  ref.watch(addressProvider);

  return ProductsNotifier(
      ref.watch(productRepositoryProvider),
      ref
  );
});

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductRepository repo;
  final Ref ref;
  ProductsNotifier(this.repo, this.ref) : super(const ProductsState());

  int _reqId = 0; // ✅ en son istek kazanır

  Future<void> loadOnce({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    if (state.initialized || state.isLoadingList) {
      debugPrint('⛔ loadOnce SKIP (initialized=${state.initialized}, loading=${state.isLoadingList})');
      return;
    }

    await _fetchList(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      search: search,
      hemenYaninda: hemenYaninda,
      sonSans: sonSans,
      yeni: yeni,
      bugun: bugun,
      yarin: yarin,
      markInitialized: true, // ✅ sadece loadOnce set eder
      sortBy: sortBy,
      sortOrder: sortOrder,
      reason: 'loadOnce',
    );
  }

  Future<void> refresh({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    int perPage = 15,
  }) async {
    debugPrint('📡 BACKEND REFRESH → categoryId=$categoryId lat=$latitude lng=$longitude sortBy=$sortBy sortOrder=$sortOrder');

    await _fetchList(
      categoryId: categoryId,
      latitude: latitude,
      longitude: longitude,
      search: search,
      hemenYaninda: hemenYaninda,
      sonSans: sonSans,
      yeni: yeni,
      bugun: bugun,
      yarin: yarin,
      markInitialized: false, // ✅ refresh initialized’ı değiştirmesin
      sortBy: sortBy,
      sortOrder: sortOrder,
      perPage: perPage,
      reason: 'refresh',
    );
  }

  Future<void> _fetchList({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    bool markInitialized = false,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    required String reason,
    int perPage = 15,
  }) async {
    final int myReq = ++_reqId;

    state = state.copyWith(isLoadingList: true, clearError: true);

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🧾 [NOTIFIER_FETCH#$myReq] START reason=$reason');
    debugPrint('   categoryId=$categoryId');
    debugPrint('   lat=$latitude lng=$longitude');
    debugPrint('   search=$search');
    debugPrint('   flags: hemen=$hemenYaninda sonSans=$sonSans yeni=$yeni bugun=$bugun yarin=$yarin');
    debugPrint('   sort=$sortBy $sortOrder');

    final bool isSearching = search != null && search.trim().isNotEmpty;

// ✅ TEST: arama varken per_page büyüt
    final int effectivePerPage = isSearching ? 200 : 15;

    debugPrint('🔎 [SEARCH_TEST#$myReq] isSearching=$isSearching per_page=$effectivePerPage search="$search"');


    try {
      final parsedProducts = await repo.fetchProductsList(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        search: search,
        perPage: perPage,//15,
        page: 1,
        sortBy: sortBy,
        sortOrder: sortOrder,
        hemenYaninda: hemenYaninda,
        sonSans: sonSans,
        yeni: yeni,
        bugun: bugun,
        yarin: yarin,
      );

      // ✅ eğer bu istek artık "eski" kaldıysa state yazma
      if (myReq != _reqId) {
        debugPrint('⏭️ [NOTIFIER_FETCH#$myReq] IGNORE (newer request exists: $_reqId)');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return;
      }

      debugPrint('📦 [NOTIFIER_FETCH#$myReq] PRODUCTS COUNT = ${parsedProducts.length}');
      if (parsedProducts.isNotEmpty) {
        final p = parsedProducts.first;
        debugPrint('📦 [NOTIFIER_FETCH#$myReq] FIRST → id=${p.id} name=${p.name} stock=${p.stock}');
      }

      state = state.copyWith(
        products: parsedProducts,
        isLoadingList: false,
        initialized: markInitialized ? true : state.initialized,
      );

      debugPrint('✅ [NOTIFIER_FETCH#$myReq] STATE UPDATED | products=${state.products.length} initialized=${state.initialized}');
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    } catch (e, st) {
      if (myReq != _reqId) {
        debugPrint('⏭️ [NOTIFIER_FETCH#$myReq] ERROR IGNORED (newer request exists: $_reqId) err=$e');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        return;
      }

      debugPrint('❌ [NOTIFIER_FETCH#$myReq] FETCH ERROR → $e');
      debugPrint(st.toString());

      state = state.copyWith(
        isLoadingList: false,
        error: e.toString(),
      );

      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }
  }

  // detail...
// lib/features/product/domain/products_notifier.dart içindeki fetchDetail

  Future<void> fetchDetail(String productId) async {
    state = state.copyWith(isLoadingDetail: true, clearError: true);
    try {
      // 1. 📍 Güncel adresi notifier içinden oku
      final address = ref.read(addressProvider);

      // 2. 🚀 Repo'ya koordinatları gönder (Repo'yu bu parametreleri alacak şekilde güncellediğini varsayıyorum)
      final product = await repo.getProductDetail(
        productId,
        lat: address.lat, // Backend bu koordinatlara göre mesafeyi hesaplayacak
        lng: address.lng,
      );

      state = state.copyWith(
        selectedProduct: product,
        isLoadingDetail: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingDetail: false,
        error: e.toString(),
      );
    }
  }

  void clearDetail() {
    state = state.copyWith(clearSelectedProduct: true);
  }
}
