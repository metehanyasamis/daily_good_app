class CreateOrderItemRequest {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? notes;

  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class CreateOrderRequest {
  final String storeId;
  final double totalAmount;
  final String paymentMethod; // Örn: "credit_card"
  final Map<String, dynamic> paymentData;
  final List<CreateOrderItemRequest> items;

  CreateOrderRequest({
    required this.storeId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentData,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'payment_data': paymentData,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
