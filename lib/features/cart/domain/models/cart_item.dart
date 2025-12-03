// lib/features/cart/domain/models/cart_item.dart

class CartItem {
  final String id;          // ürün id
  final String name;        // ürün adı
  final String shopId;      // işletme id
  final String shopName;    // işletme adı
  final String image;       // görsel (opsiyonel)
  final double price;       // birim fiyat (indirimli/yeni fiyat)
  final double originalPrice; // Eski fiyat (list_price)
  final int quantity;       // adet

  const CartItem({
    required this.id,
    required this.name,
    required this.shopId,
    required this.shopName,
    required this.image,
    required this.price,
    this.originalPrice = 0.0, // Varsayılan değer ekledik
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
        originalPrice: originalPrice,
        quantity: quantity ?? this.quantity,
      );
}