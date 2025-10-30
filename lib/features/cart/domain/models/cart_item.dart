class CartItem {
  final String id;          // ürün id
  final String name;        // ürün adı
  final String shopId;      // işletme id
  final String shopName;    // işletme adı
  final String image;       // görsel (opsiyonel)
  final double price;       // birim fiyat
  final int quantity;       // adet

  const CartItem({
    required this.id,
    required this.name,
    required this.shopId,
    required this.shopName,
    required this.image,
    required this.price,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) =>
      CartItem(
        id: id,
        name: name,
        shopId: shopId,
        shopName: shopName,
        image: image,
        price: price,
        quantity: quantity ?? this.quantity,
      );
}
