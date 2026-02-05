import '../../domain/models/cart_item.dart';

/// Backend'den gelen null veya farklı tipli alanları String'e güvenle çevirir.
String _safeString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

class CartResponseModel {
  final String id;
  final ProductDetailCart product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final StoreCartDetail store;
  final BrandCartDetail brand;

  CartResponseModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.store,
    required this.brand,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      id: _safeString(json['id']),
      product: ProductDetailCart.fromJson(Map<String, dynamic>.from(json['product'] ?? {})),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      store: StoreCartDetail.fromJson(Map<String, dynamic>.from(json['store'] ?? {})),
      brand: BrandCartDetail.fromJson(Map<String, dynamic>.from(json['brand'] ?? {})),
    );
  }

  /// Domain’e dönüşüm → CartItem
  CartItem toDomain() {
    return CartItem(
      cartItemId: id,
      productId: product.id,

      name: product.name,
      shopId: store.id,
      shopName: store.name,
      image: brand.logo,

      // 🆕 navigation
      shopAddress: store.address,
      shopLatitude: double.tryParse(store.latitude),
      shopLongitude: double.tryParse(store.longitude),

      price: unitPrice,
      originalPrice: product.listPrice,
      quantity: quantity,
    );

  }
}

class ProductDetailCart {
  final String id;
  final String name;
  final double salePrice;
  final double listPrice;

  ProductDetailCart({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.listPrice,
  });

  factory ProductDetailCart.fromJson(Map<String, dynamic> json) {
    return ProductDetailCart(
      id: _safeString(json['id']),
      name: _safeString(json['name']),
      salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
      listPrice: (json['list_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StoreCartDetail {
  final String id;
  final String name;
  final String address;
  final String latitude;
  final String longitude;

  StoreCartDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory StoreCartDetail.fromJson(Map<String, dynamic> json) {
    return StoreCartDetail(
      id: _safeString(json['id']),
      name: _safeString(json['name']),
      address: _safeString(json['address']),
      latitude: _safeString(json['latitude']),
      longitude: _safeString(json['longitude']),
    );
  }
}

class BrandCartDetail {
  final String name;
  final String logo;

  BrandCartDetail({required this.name, required this.logo});

  factory BrandCartDetail.fromJson(Map<String, dynamic> json) {
    return BrandCartDetail(
      name: _safeString(json['name']),
      logo: _safeString(json['logo']),
    );
  }
}
