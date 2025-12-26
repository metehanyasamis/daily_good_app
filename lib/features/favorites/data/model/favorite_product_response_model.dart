import 'package:flutter/material.dart';

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
    // 🕵️ Hangi veri eksik geliyor bakıyoruz:
    if (json['product'] == null) {
      debugPrint('🚨 DİKKAT: Favori objesi geldi ama içindeki "product" null! ID: ${json['id']}');
    }

    return FavoriteProductResponseModel(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      product: ProductDetail.fromJson(json['product'] ?? {
        'name': 'Ürün Bilgisi Eksik', // Fallback
        'list_price': 0,
        'sale_price': 0,
        'stock': 0,
        'image_url': ''
      }),
    );
  }

  ProductModel toDomain() {
    return ProductModel(
      id: productId,
      name: product.name,
      listPrice: product.listPrice.toDouble(),
      salePrice: product.salePrice.toDouble(),
      stock: product.stock,
      imageUrl: product.imageUrl,
      description: product.description,
      store: product.store.toStoreSummary(),
      startHour: product.startHour ?? "",
      endHour: product.endHour ?? "",
      startDate: product.startDate ?? "",
      endDate: product.endDate ?? "",
      createdAt: DateTime.tryParse(product.createdAt) ?? DateTime.now(),
    );
  }
}
