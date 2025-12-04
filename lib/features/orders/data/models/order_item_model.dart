// lib/features/orders/data/models/order_item_model.dart

class OrderItemModel {
  final String id;
  final String productName;
  final double oldPrice;
  final double newPrice;

  final DateTime orderTime;
  final DateTime pickupStart;
  final DateTime pickupEnd;

  final String pickupCode;

  final String businessId;
  final String businessName;
  final String businessAddress;
  final String businessLogo;

  final double carbonSaved;
  final bool isDelivered;

  OrderItemModel({
    required this.id,
    required this.productName,
    required this.oldPrice,
    required this.newPrice,
    required this.orderTime,
    required this.pickupStart,
    required this.pickupEnd,
    required this.pickupCode,
    required this.businessId,
    required this.businessName,
    required this.businessAddress,
    required this.businessLogo,
    required this.carbonSaved,
    required this.isDelivered,
  });
}
