class BannerModel {
  final String id;
  final String text;
  final String imagePath;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.text,
    required this.imagePath,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  static String normalizeImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final url = raw.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final cleanPath = url.startsWith('/') ? url.substring(1) : url;
    return 'https://dailygood.dijicrea.net/storage/$cleanPath';
  }
}
