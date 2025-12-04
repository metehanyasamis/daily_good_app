// lib/features/cart/data/models/cart_response_model.dart

import '../../domain/models/cart_item.dart';

// API'deki "GET /customer/cart" yanıtındaki tek bir öğeyi temsil eder
class CartResponseModel {
  final String id;
  final ProductDetail product;
  final int quantity;
  final double unitPrice; // Yeni fiyat (sale_price)
  final double totalPrice;
  final StoreDetail store;
  final BrandDetail brand;

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
      product: ProductDetail.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      store: StoreDetail.fromJson(json['store'] as Map<String, dynamic>),
      brand: BrandDetail.fromJson(json['brand'] as Map<String, dynamic>),
    );
  }

  // Domain modeline (CartItem) dönüşüm
  CartItem toDomain() {
    return CartItem(
      id: product.id,
      name: product.name,
      shopId: store.id,
      shopName: store.name,
      image: brand.logo,
      price: unitPrice,
      quantity: quantity,
      originalPrice: product.listPrice, // Eski fiyatı (list_price)
    );
  }
}

// Alt detay modelleri (API yanıtına göre)
class ProductDetail {
  final String id;
  final String name;
  final double salePrice;
  final double listPrice;

  ProductDetail({required this.id, required this.name, required this.salePrice, required this.listPrice});
  factory ProductDetail.fromJson(Map<String, dynamic> json) => ProductDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    salePrice: (json['sale_price'] as num).toDouble(),
    listPrice: (json['list_price'] as num).toDouble(),
  );
}

class StoreDetail {
  final String id;
  final String name;
  final String address;
  final String latitude;
  final String longitude;

  StoreDetail({required this.id, required this.name, required this.address, required this.latitude, required this.longitude});
  factory StoreDetail.fromJson(Map<String, dynamic> json) => StoreDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: json['latitude'] as String,
    longitude: json['longitude'] as String,
  );
// BusinessModel'a dönüşüm metodu burada eklenebilir, ancak şimdilik BusinessModel'ı mock'tan çektiğiniz için dokunmuyoruz.
}

class BrandDetail {
  final String name;
  final String logo; // image yerine logo kullanıyoruz

  BrandDetail({required this.name, required this.logo});
  factory BrandDetail.fromJson(Map<String, dynamic> json) => BrandDetail(
    name: json['name'] as String,
    logo: json['logo'] as String,
  );
}