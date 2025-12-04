// lib/features/orders/data/models/order_detail_model.dart

class OrderDetailItem {
  final String id;
  final String orderNumber;
  final String pickupCode;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? deliveryDate;

  final Map<String, dynamic> store;
  final List<dynamic> items;
  final Map<String, dynamic> payment;

  OrderDetailItem({
    required this.id,
    required this.orderNumber,
    required this.pickupCode,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.deliveryDate,
    required this.store,
    required this.items,
    required this.payment,
  });

  factory OrderDetailItem.fromJson(Map<String, dynamic> json) {
    return OrderDetailItem(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? '',
      pickupCode: json['pickup_code'] ?? '',
      status: json['status'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      deliveryDate:
      DateTime.tryParse(json['delivery_date'] ?? '') ?? null,
      store: json['store'] ?? {},
      items: json['items'] ?? [],
      payment: json['payment'] ?? {},
    );
  }
}


class StoreDetail {
  final String id;
  final String name;
  final String address;
  final String banner;

  StoreDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.banner,
  });

  factory StoreDetail.fromJson(Map<String, dynamic> json) {
    return StoreDetail(
      id: json["id"],
      name: json["name"],
      address: json["address"] ?? "",
      banner: json["banner_image_url"] ?? "",
    );
  }
}

class OrderItemDetail {
  final String id;
  final ProductInfo product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemDetail({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      id: json["id"],
      product: ProductInfo.fromJson(json["product"]),
      quantity: json["quantity"],
      unitPrice: (json["unit_price"] as num).toDouble(),
      totalPrice: (json["total_price"] as num).toDouble(),
    );
  }
}

class ProductInfo {
  final String id;
  final String name;
  final String imageUrl;

  ProductInfo({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      id: json["id"],
      name: json["name"],
      imageUrl: json["image_url"],
    );
  }
}
