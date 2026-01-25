import 'order_list_item.dart';

class OrderSummaryResponse {
  final int totalOrders;
  final double totalSavings;
  final double carbonFootprintSaved;
  final List<OrderListItem> orders;

  OrderSummaryResponse({
    required this.totalOrders,
    required this.totalSavings,
    required this.carbonFootprintSaved,
    required this.orders,
  });

  factory OrderSummaryResponse.fromJson(Map<String, dynamic> json) {
    final orders = (json['orders'] as List? ?? [])
        .map((e) => OrderListItem.fromJson(e))
        .toList();

    return OrderSummaryResponse(
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalSavings: (json['total_savings'] as num?)?.toDouble() ?? 0.0,
      carbonFootprintSaved:
      (json['carbon_footprint_saved'] as num?)?.toDouble() ?? 0.0,
      orders: orders,
    );
  }
}
