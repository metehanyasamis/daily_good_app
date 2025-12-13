class CartItem {
  final String cartItemId; // 🔥 backend cart item id
  final String productId;

  final String name;
  final String shopId;
  final String shopName;
  final String image;

  final double price;
  final double originalPrice;
  final int quantity;

  const CartItem({
    required this.cartItemId,
    required this.productId,
    required this.name,
    required this.shopId,
    required this.shopName,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.quantity,
  });

  CartItem copyWith({int? quantity}) => CartItem(
    cartItemId: cartItemId,
    productId: productId,
    name: name,
    shopId: shopId,
    shopName: shopName,
    image: image,
    price: price,
    originalPrice: originalPrice,
    quantity: quantity ?? this.quantity,
  );
}
