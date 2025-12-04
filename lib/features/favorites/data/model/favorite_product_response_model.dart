import '../../../product/data/models/product_model.dart';
import '../../../product/data/models/store_summary.dart';

class FavoriteProductResponseModel {
  final String id; // row id
  final String productId;
  late final ProductDetail product;

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

// -----------------------------------
// PRODUCT DETAIL
// -----------------------------------
class ProductDetail {
  final String id;
  final String name;
  final int listPrice;
  final int salePrice;
  final int stock;
  final String imageUrl;
  final String? description;
  final String? startHour;
  final String? endHour;
  final String? startDate;
  final String? endDate;
  final StoreInProductDetail store;
  final String createdAt;

  ProductDetail({
    required this.id,
    required this.name,
    required this.listPrice,
    required this.salePrice,
    required this.stock,
    required this.imageUrl,
    this.description,
    this.startHour,
    this.endHour,
    this.startDate,
    this.endDate,
    required this.store,
    required this.createdAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      listPrice: json['list_price'] ?? 0,
      salePrice: json['sale_price'] ?? 0,
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'] ?? "",
      description: json['description'],
      startHour: json['start_hour'],
      endHour: json['end_hour'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      store: StoreInProductDetail.fromJson(json['store']),
      createdAt: json['created_at'] ?? "",
    );
  }
}

// -----------------------------------
// STORE DETAIL INSIDE PRODUCT
// -----------------------------------
class StoreInProductDetail {
  final String id;
  final String name;
  final String address;
  final String imageUrl;

  StoreInProductDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
  });

  factory StoreInProductDetail.fromJson(Map<String, dynamic> json) {
    return StoreInProductDetail(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      imageUrl: json['image_url'] ?? "",
    );
  }

  StoreSummary toStoreSummary() {
    return StoreSummary(
      id: id,
      name: name,
      address: address,
      imageUrl: imageUrl,
    );
  }
}
