import 'package:flutter/material.dart';

class OrderDetailResponse {
  final String id;
  final String orderNumber;
  final String pickupCode;
  final String status;
  final String statusLabel;
  final double totalAmount;
  final DateTime? deliveryDate;
  final OrderReview? review;

  final StoreInOrder store;
  final List<OrderProductItem> items;
  final PaymentInfo payment;

  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDetailResponse({
    required this.id,
    required this.orderNumber,
    required this.pickupCode,
    required this.status,
    required this.statusLabel,
    required this.totalAmount,
    required this.deliveryDate,
    required this.review,
    required this.store,
    required this.items,
    required this.payment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) {

    // 🕵️‍♂️🕵️‍♂️🕵️‍♂️ KANIT LOGLARI (Bunu ekle) 🕵️‍♂️🕵️‍♂️🕵️‍♂️
    try {
      debugPrint("=================================================================");
      debugPrint("🕵️‍♂️ [KANIT] Sipariş ID: ${json['id']}");
      debugPrint("🕵️‍♂️ [KANIT] Raw Review Objesi: ${json['review']}"); // Burası null mı dolu mu?

      if (json['review'] != null) {
        debugPrint("🕵️‍♂️ [KANIT] Review ID: ${json['review']['id']}");
      } else {
        debugPrint("🕵️‍♂️ [KANIT] Review NULL geldi! Backend göndermiyor.");
      }
      debugPrint("=================================================================");
    } catch (e) {
      debugPrint("🕵️‍♂️ [KANIT] Log basarken hata oldu: $e");
    }
    // 🕵️‍♂️🕵️‍♂️🕵️‍♂️ KANIT BİTİŞ 🕵️‍♂️🕵️‍♂️🕵️‍♂️

    return OrderDetailResponse(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? '',
      pickupCode: json['pickup_code'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      deliveryDate: json['delivery_date'] != null
          ? DateTime.tryParse(json['delivery_date'])
          : null,
      review: json['review'] != null ? OrderReview.fromJson(json['review']) : null,
      store: StoreInOrder.fromJson(json['store'] ?? {}),
      items: (json['items'] as List? ?? [])
          .map((e) => OrderProductItem.fromJson(e))
          .toList(),
      payment: PaymentInfo.fromJson(json['payment'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class StoreInOrder {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String address;
  final String bannerImageUrl;
  final bool isFavorite;

  StoreInOrder({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.bannerImageUrl,
    required this.isFavorite,
  });

  factory StoreInOrder.fromJson(Map<String, dynamic> json) {
    return StoreInOrder(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] ?? '',
      bannerImageUrl: json['banner_image_url'] ?? json['banner_image'] ?? '',
      isFavorite: json['is_favorite'] == true,
    );
  }
}

class OrderProductItem {
  final String id;
  final ProductInOrder product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  OrderProductItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  factory OrderProductItem.fromJson(Map<String, dynamic> json) {
    return OrderProductItem(
      id: json['id']?.toString() ?? '',
      product: ProductInOrder.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }
}

class ProductInOrder {
  final String id;
  final String name;
  final String imageUrl;
  final String? startHour;
  final String? endHour;
  final String? startDate;
  final String? endDate;
  final double listPrice;
  final double sellingPrice;

  ProductInOrder({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.startHour,
    required this.endHour,
    required this.startDate,
    required this.endDate,
    required this.listPrice,
    required this.sellingPrice,
  });

  factory ProductInOrder.fromJson(Map<String, dynamic> json) {
    return ProductInOrder(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      startHour: json['start_hour'],
      endHour: json['end_hour'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      listPrice: (json['list_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class OrderReview {
  final String id;
  final String? comment;
  final int serviceRating;
  final int productQuantityRating;
  final int productTasteRating;
  final int productVarietyRating;

  OrderReview({
    required this.id,
    this.comment,
    required this.serviceRating,
    required this.productQuantityRating,
    required this.productTasteRating,
    required this.productVarietyRating,
  });

  factory OrderReview.fromJson(Map<String, dynamic> json) {
    return OrderReview(
      id: json['id']?.toString() ?? '',
      comment: json['comment'],
      // API'den gelen snake_case isimleri Dart modeline (camelCase) eşliyoruz
      serviceRating: json['service_rating'] ?? 0,
      productQuantityRating: json['product_quantity_rating'] ?? 0,
      productTasteRating: json['product_taste_rating'] ?? 0,
      productVarietyRating: json['product_variety_rating'] ?? 0,
    );
  }
}


class PaymentInfo {
  final String paymentMethod;
  final String paymentMethodLabel;
  final String paymentStatus;
  final String paymentStatusLabel;
  final double amount;

  PaymentInfo({
    required this.paymentMethod,
    required this.paymentMethodLabel,
    required this.paymentStatus,
    required this.paymentStatusLabel,
    required this.amount,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      paymentMethod: json['payment_method'] ?? '',
      paymentMethodLabel: json['payment_method_label'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentStatusLabel: json['payment_status_label'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
