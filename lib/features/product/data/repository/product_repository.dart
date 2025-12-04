import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

// Pagination metadatasını tutar
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    // API yanıtındaki 'meta' veya 'pagination' alanına göre düzenlenebilir.
    // Varsayılan olarak API'dan gelen 'meta' veya 'pagination' objesinin
    // doğrudan PaginationMeta.fromJson'a geçtiğini varsayıyoruz.
    final pagination = json;
    return PaginationMeta(
      currentPage: pagination['current_page'] as int,
      lastPage: pagination['last_page'] as int,
      perPage: pagination['per_page'] as int,
      total: pagination['total'] as int,
    );
  }
}

// 🔥 YENİ: Listeleme sonucunu tutacak yardımcı sınıf (Record hatasını giderir)
class ProductListResponse {
  final List<ProductModel> products;
  final PaginationMeta meta;

  ProductListResponse({required this.products, required this.meta});
}


class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  /// Ürün listesini API'den çeker (GET /products/category)
  Future<ProductListResponse> fetchProducts({
    String? categoryId,
    double? latitude,
    double? longitude,
    int page = 1,
    int perPage = 15,
    // 🔥 EKLENEN PARAMETRELER: Controller tarafından iletilenler
    String? name,
    String? sortBy,
    String? sortOrder,
    // Diğer filtreler
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) async {
    debugPrint('⭐ Ürün listesi çekiliyor: Sayfa $page');
    try {
      final response = await _dio.get(
        '/products', // API endpoint'iniz
        queryParameters: {
          'category_id': categoryId,
          'latitude': latitude,
          'longitude': longitude,
          'page': page,
          'per_page': perPage,
          // 🔥 API SORGUSUNA EKLENEN PARAMETRELER
          'name': name,
          'sort_by': sortBy, // API'da snake_case kullanıldığı varsayıldı
          'sort_order': sortOrder, // API'da snake_case kullanıldığı varsayıldı
          'hemen_yaninda': hemenYaninda,
          'son_sans': sonSans,
          'yeni': yeni,
          'bugun': bugun,
          'yarin': yarin,
          // Null olanlar otomatik olarak istekten düşecektir (Dio'nun varsayılan davranışı).
        },
      );

      final dataList = response.data['data'] as List;
      final products = dataList
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // API yanıtının top-level'da 'meta' içerdiği varsayımıyla düzeltildi
      final meta = PaginationMeta.fromJson(response.data as Map<String, dynamic>);

      debugPrint('✅ Ürün listesi başarıyla çekildi: ${products.length} adet');
      return ProductListResponse(products: products, meta: meta);

    } on DioException catch (e) {
      debugPrint('❌ Ürün listesi çekme HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }

  /// Ürün detayını API'den çeker (GET /products/{productId})
  Future<ProductModel> fetchProductDetail(String productId) async {
    debugPrint('⭐ Ürün detayı çekiliyor: $productId');
    try {
      final response = await _dio.get('/products/$productId');

      final productData = response.data['data'] as Map<String, dynamic>;
      final product = ProductModel.fromJson(productData);

      debugPrint('✅ Ürün detayı başarıyla çekildi.');
      return product;
    } on DioException catch (e) {
      debugPrint('❌ Ürün detayı çekme HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }
}