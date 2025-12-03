// lib/features/favorites/data/models/favorite_shop_response_model.dart

import '../../../businessShop/data/model/businessShop_model.dart';

// GET /customer/favorites yanıtındaki tek bir öğeyi temsil eder
class FavoriteShopResponseModel {
  final String id;
  final StoreDetail store;
  // BrandDetail'ı doğrudan API yanıtından alıyoruz, içinde sadece id ve name var.
  // Ancak StoreDetail içinde banner_image var.
  final BrandDetail brand;

  FavoriteShopResponseModel({
    required this.id,
    required this.store,
    required this.brand,
  });

  factory FavoriteShopResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteShopResponseModel(
      id: json['id'] as String,
      store: StoreDetail.fromJson(json['store'] as Map<String, dynamic>),
      brand: BrandDetail.fromJson(json['store']['brand'] as Map<String, dynamic>),
      // NOT: API yanıt örneğinde brand, store içinde gömülmüş.
    );
  }

  // Domain modeline (BusinessModel) dönüşüm
  BusinessModel toDomain() {
    return BusinessModel(
      id: store.id,
      name: store.name,
      address: store.address,
      latitude: store.latitude,
      longitude: store.longitude,

      // ✅ LOGO ve BANNER ataması: API yanıtında LOGO bilgisi eksik görünüyor.
      // Mock'ta BusinessModel'in ihtiyacı olan alanlara atama yapıyoruz.
      // API'den LOGO gelmediği için varsayılan bir değer veya 'banner'ı kullanırız.
      businessShopLogoImage: 'https://example.com/default_logo.png',
      businessShopBannerImage: store.bannerImage, // StoreDetail içindeki banner_image kullanıldı

      // Zorunlu alanlar için Placeholderlar
      workingHours: "Bilinmiyor",
      products: const [],
      rating: 4.5,
      distance: 2.1,
      isFavorite: true,
    );
  }
}

// Alt detay modelleri (API yanıtına göre)
class StoreDetail {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String bannerImage; // ✅ Yeni eklendi (API yanıtından)

  StoreDetail({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.bannerImage, // ✅ Yeni eklendi
  });

  factory StoreDetail.fromJson(Map<String, dynamic> json) => StoreDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    bannerImage: json['banner_image'] as String, // ✅ Yeni parse edildi
  );
}

class BrandDetail {
  final String id; // API yanıtına göre eklendi
  final String name;

  BrandDetail({required this.id, required this.name});
  factory BrandDetail.fromJson(Map<String, dynamic> json) => BrandDetail(
    id: json['id'] as String,
    name: json['name'] as String,
  );
}