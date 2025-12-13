import '../../../product/data/models/product_detail.dart';
import '../../../product/data/models/product_model.dart';

class FavoriteProductResponseModel {
  final String id;
  final String productId;
  final ProductDetail product;

  FavoriteProductResponseModel({
    required this.id,
    required this.productId,
    required this.product,
  });

  factory FavoriteProductResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProductResponseModel(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      product: ProductDetail.fromJson(json['product']),
    );
  }

  ProductModel toDomain() {
    return ProductModel(
      id: product.id,
      name: product.name,
      listPrice: product.listPrice.toDouble(),
      salePrice: product.salePrice.toDouble(),
      stock: product.stock,
      imageUrl: product.imageUrl,
      store: product.store.toStoreSummary(),
      startHour: product.startHour ?? "",
      endHour: product.endHour ?? "",
      startDate: product.startDate ?? "",
      endDate: product.endDate ?? "",
      createdAt: DateTime.tryParse(product.createdAt) ?? DateTime.now(),
    );
  }
}
