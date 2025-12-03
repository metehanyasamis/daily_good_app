// ProductModel, ProductStoreModel ve BrandModel tanımları tek bir dosyada.
// Bu, projenin geri kalanında karışıklığa neden olabilir,
// ancak mevcut dosya yapısına uygun olarak koruyorum.

// API yanıtındaki Brand objesini temsil eder
// 🔥 Bu tanım ProductStoreModel'den ProductModel'e taşındı.
class BrandModel {
  final String id;
  final String name;
  final String? logoUrl;

  BrandModel({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
    );
  }
}

// API yanıtındaki Store objesi ProductModel içinde gömülü olarak geliyor
class ProductStoreModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? bannerImageUrl;
  final String? address;
  final bool isFavorite;
  final double distanceKm;
  final BrandModel brand;

  ProductStoreModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.bannerImageUrl,
    this.address,
    required this.isFavorite,
    required this.distanceKm,
    required this.brand,
  });

  factory ProductStoreModel.fromJson(Map<String, dynamic> json) {
    return ProductStoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bannerImageUrl: json['banner_image_url'] as String?,
      address: json['address'] as String?,
      isFavorite: json['is_favorite'] as bool,
      distanceKm: (json['distance_km'] as num).toDouble(),
      brand: BrandModel.fromJson(json['brand'] as Map<String, dynamic>),
    );
  }
}


class ProductModel {
  final String id;
  final String name;
  final double listPrice;
  final double salePrice;
  final int stock;
  final String imageUrl;
  final ProductStoreModel store;
  final String startHour;
  final String endHour;
  final String startDate;
  final String endDate;
  final DateTime createdAt;

  // ProductDetail içinde var olan ancak ProductModel'e zorunlu alınmayan,
  // ancak UI'da gerekebilecek alanları ekliyoruz (Örneğin ProductDetailScreen'de description).
  // Bu alanı optional olarak eklemek en güvenli yoldur.
  // Not: Eğer bu alan ProductModel'in constructor'ında hiç yoksa, aşağıdaki alanı silebilirsiniz.
  // Bu düzeltmede, muhtemelen UI'da kullanmak üzere description'ı optional olarak ekliyorum.
  final String? description;

  ProductModel({
    required this.id,
    required this.name,
    required this.listPrice,
    required this.salePrice,
    required this.stock,
    required this.imageUrl,
    required this.store,
    required this.startHour,
    required this.endHour,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.description, // Optional olarak eklendi
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      listPrice: (json['list_price'] as num).toDouble(),
      salePrice: (json['sale_price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String,
      store: ProductStoreModel.fromJson(json['store'] as Map<String, dynamic>),
      startHour: json['start_hour'] as String,
      endHour: json['end_hour'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      description: json['description'] as String?, // API'dan geliyorsa yakala
    );
  }

  // copyWith metodu güncellendi
  ProductModel copyWith({
    String? id,
    String? name,
    double? listPrice,
    double? salePrice,
    int? stock,
    String? imageUrl,
    ProductStoreModel? store,
    String? startHour,
    String? endHour,
    String? startDate,
    String? endDate,
    DateTime? createdAt,
    String? description, // copyWith'e eklendi
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      listPrice: listPrice ?? this.listPrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      store: store ?? this.store,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description, // copyWith'e eklendi
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;

  // 💡 UI için Getter'lar
  String get pickupTimeText => '$startHour - $endHour';
  String get stockLabel => 'Son $stock'; // API'den gelen `stock` kullanılır.

  // 🔥 Mock'taki businessId ve distance'ı store modelinden almalıyız:
  String get businessId => store.id;
  double get distance => store.distanceKm;
  bool get isFavorite => store.isFavorite; // StoreModel'den çekildi

}