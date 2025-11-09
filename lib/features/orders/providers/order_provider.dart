import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order_model.dart';

/// Ana sipariş listesi sağlayıcısı
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderItem>>(
      (ref) => OrdersNotifier(),
);

/// Aktif (teslim edilmemiş) sipariş var mı?
final hasActiveOrderProvider = Provider<bool>((ref) {
  final orders = ref.watch(ordersProvider);
  return orders.any((o) => !o.isDelivered);
});

class OrdersNotifier extends StateNotifier<List<OrderItem>> {
  OrdersNotifier() : super([]);

  void addOrder(OrderItem item) {
    state = [...state, item];
  }

  void markDelivered(String id) {
    state = [
      for (final o in state)
        if (o.id == id) o.copyWith(isDelivered: true) else o
    ];
  }
}

extension on OrderItem {
  OrderItem copyWith({bool? isDelivered}) {
    return OrderItem(
      id: id,
      productName: productName,
      oldPrice: oldPrice,
      newPrice: newPrice,
      orderTime: orderTime,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupCode: pickupCode,
      businessName: businessName,
      businessAddress: businessAddress,
      businessLogo: businessLogo,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}
