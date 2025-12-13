import '../../../stores/data/model/store_summary.dart';

class FavoriteStoreResponseModel {
  final String id;
  final StoreSummary store;

  FavoriteStoreResponseModel({
    required this.id,
    required this.store,
  });

  factory FavoriteStoreResponseModel.fromJson(Map<String, dynamic> json) {
    final s = json['store'];
    return FavoriteStoreResponseModel(
      id: json['id'].toString(),
      store: StoreSummary(
        id: s['id'].toString(),
        name: s['name'] ?? '',
        address: s['address'] ?? '',
        imageUrl: s['banner_image'] ?? '',
        distanceKm: (s['distance_km'] as num?)?.toDouble(),
        overallRating: (s['overall_rating'] as num?)?.toDouble(),
      ),
    );
  }
}
