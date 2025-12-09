import '../../../stores/data/model/store_summary.dart';

class FavoriteShopResponseModel {
  final String id;
  final StoreDetail store;

  FavoriteShopResponseModel({
    required this.id,
    required this.store,
  });

  factory FavoriteShopResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteShopResponseModel(
      id: json['id'].toString(),
      store: StoreDetail.fromJson(json['store']),
    );
  }

  StoreSummary toDomain() {
    return StoreSummary(
      id: store.id,
      name: store.name,
      address: store.address,
      imageUrl: store.imageUrl,
      distanceKm: store.distanceKm,
      overallRating: store.overallRating,
    );
  }
}

class StoreDetail {
  final String id;
  final String name;
  final String address;
  final double? distanceKm;
  final double? overallRating;
  final String imageUrl;

  StoreDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.distanceKm,
    this.overallRating,
  });

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    return StoreDetail(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      imageUrl: json['image_url'] ?? "",
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      overallRating: (json['overall_rating'] as num?)?.toDouble(),
    );
  }
}
