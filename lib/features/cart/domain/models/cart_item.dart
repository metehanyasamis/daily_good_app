class CartItem {
  final String id;
  final String name;
  final String shopId;
  final String shopName;
  final String image;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.shopId,
    required this.shopName,
    required this.image,
    required this.price,
    this.quantity = 1,
  });
}
