// lib/features/product/domain/products_notifier.dart
// Güncelleme: loadOnce / refresh artık sortBy / sortOrder alıyor ve repo'ya geçiriyor.

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

  // =============================
  // LIST → GET /products/category
  // =============================
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
    // 🔐 ÇİFT KORUMA
    if (state.initialized || state.isLoadingList) {
      debugPrint(
          '⛔ loadOnce SKIP (initialized=${state.initialized}, loading=${state.isLoadingList})');
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
    debugPrint(
        '📡 BACKEND REFRESH → categoryId=$categoryId lat=$latitude lng=$longitude sortBy=$sortBy sortOrder=$sortOrder');

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
      final res = await repo.fetchProducts(
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

      state = state.copyWith(
        products: res.products,
        isLoadingList: false,
        initialized: markInitialized ? true : state.initialized,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingList: false,
        error: e.toString(),
      );
    }
  }

  // =========================
  // DETAIL → GET /products/{id}
  // =========================
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