import '../../../stores/data/model/store_summary.dart';

class FavoriteStoreResponseModel {
  final String id; // Favori kayıt ID'si
  final StoreSummary store;

  FavoriteStoreResponseModel({
    required this.id,
    required this.store,
  });

  factory FavoriteStoreResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteStoreResponseModel(
      id: json['id'].toString(),
      // 🔥 Senin mevcut StoreSummary yapını kullanıyoruz
      store: StoreSummary.fromJson(json['store'] ?? {}),
    );
  }
}