import '../../../stores/data/model/store_summary.dart';

class FavoriteStoreResponseModel {
  final String id;
  final String storeId;
  final StoreSummary? store; // 🎯 1. BURASI: Soru işareti ekledik (Nullable)

  FavoriteStoreResponseModel({
    required this.id,
    required this.storeId,
    this.store, // 🎯 2. BURASI: required'ı kaldırdık
  });

  factory FavoriteStoreResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteStoreResponseModel(
      id: json['id'] ?? "",
      storeId: json['store_id'] ?? "",
      // 🎯 3. BURASI: Gelen store null ise hata vermeden null atar
      store: json['store'] != null ? StoreSummary.fromJson(json['store']) : null,
    );
  }
}