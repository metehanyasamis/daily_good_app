// lib/features/orders/data/mapper/order_mapper.dart

import '../models/order_list_item.dart';
import '../models/order_details_response.dart';
import '../models/order_model.dart';

class OrderMapper {

  /// GET /customer/orders → UI
  static OrderItem fromList(
      OrderListItem item, {
        required double carbonPerOrder,
      }) {
    final created = item.createdAt;

    return OrderItem(
      id: item.id,
      productName: 'Sürpriz Paket',
      oldPrice: item.totalAmount,
      newPrice: item.totalAmount,
      orderTime: created,
      pickupStart: created,
      pickupEnd: created.add(const Duration(hours: 2)),
      pickupCode: item.pickupCode,
      businessId: item.storeId,
      businessName: item.storeName,
      businessAddress: '',
      businessLogo: 'assets/logos/dailyGood_tekSaatLogo.png',
      carbonSaved: carbonPerOrder,
      isDelivered: item.status != 'pending',
    );
  }

  /// GET /customer/orders/{id} veya POST response → UI
  static OrderItem fromDetail(OrderDetailResponse detail) {
    final product =
    detail.items.isNotEmpty ? detail.items.first.product : null;

    final deliveryDate = detail.deliveryDate ?? detail.createdAt;

    DateTime pickupStart = detail.createdAt;
    DateTime pickupEnd = detail.createdAt.add(const Duration(hours: 2));

    if (product?.startHour != null && product?.endHour != null) {
      pickupStart = _combine(deliveryDate, product!.startHour!);
      pickupEnd = _combine(deliveryDate, product.endHour!);
    }

    return OrderItem(
      id: detail.id,
      productName: product?.name ?? 'Sürpriz Paket',
      oldPrice: product?.listPrice ?? detail.totalAmount,
      newPrice: product?.sellingPrice ?? detail.totalAmount,
      orderTime: detail.createdAt,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupCode: detail.pickupCode,
      businessId: detail.store.id,
      businessName: detail.store.name,
      businessAddress: detail.store.address,
      businessLogo: detail.store.bannerImageUrl.isNotEmpty
          ? detail.store.bannerImageUrl
          : 'assets/logos/dailyGood_tekSaatLogo.png',
      carbonSaved: 0.0,
      isDelivered: detail.status != 'pending',
    );
  }

  static DateTime _combine(DateTime date, String hhmmss) {
    final p = hhmmss.split(':');
    final h = int.tryParse(p[0]) ?? 0;
    final m = int.tryParse(p[1]) ?? 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }
}
