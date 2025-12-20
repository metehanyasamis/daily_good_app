class CategoryModel {
  final int id;
  final String name;
  final String? image; // 🔥 NULLABLE

  CategoryModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      image: json['image'], // null olabilir
    );
  }
}
