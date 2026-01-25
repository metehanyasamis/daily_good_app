class OrderListItem {
  final String id;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final String pickupCode;
  final double totalAmount;
  final int itemsCount;
  final DateTime createdAt;

  final String storeId;
  final String storeName;

  OrderListItem({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.pickupCode,
    required this.totalAmount,
    required this.itemsCount,
    required this.createdAt,
    required this.storeId,
    required this.storeName,
  });

  factory OrderListItem.fromJson(Map<String, dynamic> json) {
    final store = json['store'] ?? {};

    return OrderListItem(
      id: json['id'].toString(),
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? '',
      pickupCode: json['pickup_code'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      itemsCount: json['items_count'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      storeId: store['id']?.toString() ?? '',
      storeName: store['name'] ?? '',
    );
  }
}
