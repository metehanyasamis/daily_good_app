// lib/features/product/domain/products_notifier.dart
import 'package:flutter/material.dart';
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

    try {
      // Use the flat helper to get a List<ProductModel> (handles grouped response)
      final parsedProducts = await repo.fetchProductsFlat(
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

      debugPrint('PRODUCTS NOTIFIER: parsedProducts length = ${parsedProducts.length}');
      if (parsedProducts.isNotEmpty) {
        // try to print some identifying fields safely
        final first = parsedProducts.first;
        try {
          debugPrint('PRODUCTS NOTIFIER: sample product -> id=${(first as dynamic).id}, name=${(first as dynamic).name}');
        } catch (_) {
          debugPrint('PRODUCTS NOTIFIER: sample product -> ${first.toString()}');
        }
      }

      state = state.copyWith(
        products: parsedProducts,
        isLoadingList: false,
        initialized: markInitialized ? true : state.initialized,
      );

      debugPrint('PRODUCTS NOTIFIER: state.products length AFTER set -> ${state.products.length}');
    } catch (e, st) {
      debugPrint('PRODUCTS NOTIFIER: fetch error -> $e\n$st');
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