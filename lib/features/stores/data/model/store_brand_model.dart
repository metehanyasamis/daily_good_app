// lib/features/stores/data/models/brand_model.dart

class StoreBrandModel {
  final String id;
  final String name;
  final String logoUrl;

  StoreBrandModel({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory StoreBrandModel.fromJson(Map<String, dynamic> json) {
    return StoreBrandModel(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      logoUrl: json['logo_url'] ?? "",
    );
  }
}
