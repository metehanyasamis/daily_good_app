import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';

/// LOCAL ORDER STATE
/// Yalnızca:
/// - ödeme sonrası ekrana OrderItem eklemek
/// - teslim edildi olarak işaretlemek
/// için kullanılır.

final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderItem>>(
      (ref) => OrdersNotifier(),
);

class OrdersNotifier extends StateNotifier<List<OrderItem>> {
  OrdersNotifier() : super([]);

  /// Yeni sipariş ekle
  void addOrder(OrderItem item) {
    state = [...state, item];
  }

  /// Siparişi teslim edilmiş yap
  void markDelivered(String id) {
    state = [
      for (final o in state)
        if (o.id == id) o.copyWith(isDelivered: true) else o
    ];
  }
}

extension OrderCopy on OrderItem {
  OrderItem copyWith({
    bool? isDelivered,
  }) {
    return OrderItem(
      id: id,
      productName: productName,
      oldPrice: oldPrice,
      newPrice: newPrice,
      orderTime: orderTime,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupCode: pickupCode,
      businessId: businessId,
      businessName: businessName,
      businessAddress: businessAddress,
      businessLogo: businessLogo,
      carbonSaved: carbonSaved,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}
