class OrderProductItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final int quantity;

  OrderProductItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) {
    return OrderProductItem(
      id: json['id']?.toString() ?? "",
      name: json['name'] ?? "",
      imageUrl: json['image_url'] ?? "",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 1,
    );
  }
}
