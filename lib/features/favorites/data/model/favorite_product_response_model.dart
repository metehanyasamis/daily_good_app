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

    // 🔍 TEŞHİS LOGU: API'den ne geliyor, biz ne görüyoruz?
    debugPrint('--- [FAV_DEBUG_START] ---');
    debugPrint('Ürün: ${product.name}');
    debugPrint('Mağaza: ${product.store.name}');
    debugPrint('Gelen Ham Puan: ${product.store.overallRating}');
    debugPrint('Gelen Ham Mesafe: ${product.store.distanceKm}');
    debugPrint('--- [FAV_DEBUG_END] ---');


    // 1. Önce dükkan özetini ham veriden alalım
    final storeSummary = product.store.toStoreSummary();

    // 2. Mağazanın puanını ve mesafesini al (ProductDetail içindeki Store objesinden)
    final double realRating = product.store.overallRating;
    // Eğer StoreInProductDetail içine distanceKm eklediysen onu kullan,
    // eklemediysen bile toStoreSummary'nin içini düzeltmen şart.
    final double? realDistance = product.store.distanceKm; // 👈 Bunu da çekmelisin!
    final String productId = product.id.toString();



    return ProductModel(
      id: productId,
      name: product.name,
      listPrice: product.listPrice.toDouble(),
      salePrice: product.salePrice.toDouble(),
      stock: product.stock,
      imageUrl: product.imageUrl,
      description: product.description,

      // 🔥 KRİTİK DÜZELTME 1: StoreSummary içindeki puanı da zorla güncelliyoruz
      store: storeSummary.copyWith(
        overallRating: realRating,
        distanceKm: realDistance, // Artık null kalmayacak
      ),
      // 🔥 KRİTİK DÜZELTME 2: Ürün modelinin kendi puanını da güncelliyoruz
      rating: realRating,

      startHour: product.startHour,
      endHour: product.endHour,
      startDate: product.startDate ?? "",
      endDate: product.endDate ?? "",
      createdAt: product.createdAt,
    );
  }
}
