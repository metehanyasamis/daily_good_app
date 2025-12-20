import 'product_model.dart';

class ProductListResponse {
  final List<ProductModel> products;

  ProductListResponse({required this.products});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json["data"] as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();

    return ProductListResponse(products: list);
  }

  static List<ProductModel> fromRawList(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) => ProductModel.fromJson(e)).toList();
  }
}

