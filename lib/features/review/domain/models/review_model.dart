import '../../data/models/review_response_model.dart';

class ReviewModel {
  final String id;
  final String storeId;

  final String userName;

  final int serviceRating;
  final int productQuantityRating;
  final int productTasteRating;
  final int productVarietyRating;

  final String? comment;

  /// Kullanıcının bu yoruma verdiği ortalama puan
  double get averageRating {
    return (serviceRating +
        productQuantityRating +
        productTasteRating +
        productVarietyRating) /
        4.0;
  }

  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.storeId,
    required this.userName,
    required this.serviceRating,
    required this.productQuantityRating,
    required this.productTasteRating,
    required this.productVarietyRating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromResponse(String storeId, ReviewResponseModel r) {
    return ReviewModel(
      id: r.id,
      storeId: storeId,
      userName: r.customer?.name ?? "Kullanıcı",
      serviceRating: r.serviceRating,
      productQuantityRating: r.productQuantityRating,
      productTasteRating: r.productTasteRating,
      productVarietyRating: r.productVarietyRating,
      comment: r.comment,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  Map<String, int> toRatingMap() {
    return {
      "Servis": serviceRating,
      "Ürün Miktarı": productQuantityRating,
      "Ürün Lezzeti": productTasteRating,
      "Ürün Çeşitliliği": productVarietyRating,
    };
  }
}
