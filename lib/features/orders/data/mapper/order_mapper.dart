// lib/features/orders/data/mapper/order_mapper.dart

import '../models/order_list_item.dart';
import '../models/order_detail_model.dart';
import '../models/order_item_model.dart';


class OrderMapper {

  /// List endpoint → UI modeli
  static OrderItemModel fromList(OrderListItem item, double carbonPerOrder) {
    final created = item.createdAt;

    return OrderItemModel(
      id: item.id,
      productName: "Sürpriz Paket",
      oldPrice: item.totalAmount,
      newPrice: item.totalAmount,
      orderTime: created,
      pickupStart: created,
      pickupEnd: created.add(const Duration(hours: 2)),
      pickupCode: item.pickupCode,
      businessId: item.storeId,
      businessName: item.storeName,
      businessAddress: '',
      businessLogo: "assets/logos/dailyGood_tekSaatLogo.png",
      carbonSaved: carbonPerOrder,
      isDelivered: item.status != "pending",
    );
  }

  /// Detay endpoint → UI modeli
  static OrderItemModel fromDetail(OrderDetailItem detail) {
    final store = detail.store;
    final items = detail.items;
    final product = items.isNotEmpty ? items.first['product'] : null;

    final name = product?['name'] ?? "Sürpriz Paket";
    final listPrice = (product?['list_price'] as num?)?.toDouble() ??
        detail.totalAmount;
    final sellingPrice =
        (product?['selling_price'] as num?)?.toDouble() ??
            detail.totalAmount;

    final deliveryDate = detail.deliveryDate ?? detail.createdAt;

    DateTime pickupStart = detail.createdAt;
    DateTime pickupEnd = detail.createdAt.add(const Duration(hours: 2));

    if (product?['start_hour'] != null && product?['end_hour'] != null) {
      pickupStart = _combine(deliveryDate, product!['start_hour']);
      pickupEnd = _combine(deliveryDate, product['end_hour']);
    }

    return OrderItemModel(
      id: detail.id,
      productName: name,
      oldPrice: listPrice,
      newPrice: sellingPrice,
      orderTime: detail.createdAt,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupCode: detail.pickupCode,
      businessId: store['id']?.toString() ?? '',
      businessName: store['name'] ?? '',
      businessAddress: store['address'] ?? '',
      businessLogo: store['banner_image_url'] ?? '',
      carbonSaved: 0.0,
      isDelivered: detail.status != "pending",
    );
  }

  static DateTime _combine(DateTime date, String hhmmss) {
    final parts = hhmmss.split(":");
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }
}

