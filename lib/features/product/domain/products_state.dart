// lib/features/product/domain/products_state.dart

import '../data/models/product_model.dart';

class ProductsState {
  final List<ProductModel> products;
  final ProductModel? selectedProduct;

  /// Liste yükleniyor mu? (Home, Explore, Category vb.)
  final bool isLoadingList;

  /// Detay yükleniyor mu? (Product Detail)
  final bool isLoadingDetail;

  /// İlk load yapıldı mı? (loadOnce kontrolü için)
  final bool initialized;

  /// Hata mesajı (opsiyonel)
  final String? error;

  const ProductsState({
    this.products = const [],
    this.selectedProduct,
    this.isLoadingList = false,
    this.isLoadingDetail = false,
    this.initialized = false,
    this.error,
  });

  /// 🔥 GERİYE DÖNÜK UYUMLULUK
  /// Home / eski ekranlar `state.isLoading` diyebilsin diye
  bool get isLoading => isLoadingList || isLoadingDetail;

  ProductsState copyWith({
    List<ProductModel>? products,
    ProductModel? selectedProduct,
    bool? isLoadingList,
    bool? isLoadingDetail,
    bool? initialized,
    String? error,
    bool clearError = false,
    bool clearSelectedProduct = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      selectedProduct:
      clearSelectedProduct ? null : (selectedProduct ?? this.selectedProduct),
      isLoadingList: isLoadingList ?? this.isLoadingList,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      initialized: initialized ?? this.initialized,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
