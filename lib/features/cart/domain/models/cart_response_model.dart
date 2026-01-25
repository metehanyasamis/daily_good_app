import '../../domain/models/cart_item.dart';

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
      id: json['id'] as String,
      product: ProductDetailCart.fromJson(json['product']),
      quantity: json['quantity'],
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      store: StoreCartDetail.fromJson(json['store']),
      brand: BrandCartDetail.fromJson(json['brand']),
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
      id: json['id'],
      name: json['name'],
      salePrice: (json['sale_price'] as num).toDouble(),
      listPrice: (json['list_price'] as num).toDouble(),
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
      id: json['id'],
      name: json['name'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}

class BrandCartDetail {
  final String name;
  final String logo;

  BrandCartDetail({required this.name, required this.logo});

  factory BrandCartDetail.fromJson(Map<String, dynamic> json) {
    return BrandCartDetail(
      name: json['name'],
      logo: json['logo'],
    );
  }
}
