// lib/features/orders/data/order_model.dart

class OrderItem {
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
  bool isDelivered;

  OrderItem({
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
    this.carbonSaved = 0.0,
    this.isDelivered = false,
  });

  Duration get remainingTime => pickupEnd.difference(DateTime.now());

  /// 0–1 arası progress (1 = süre dolmuş)
  double get progress {
    final total = pickupEnd.difference(orderTime).inSeconds;
    final left = pickupEnd.difference(DateTime.now()).inSeconds;
    if (total <= 0) return 1;
    return 1 - (left / total).clamp(0, 1);
  }

  // ---------------------------------------------------------------------------
  // 1) GET /customer/orders  → list içindeki tek tek order için
  // ---------------------------------------------------------------------------
  factory OrderItem.fromListJson(
      Map<String, dynamic> json, {
        double carbonPerOrder = 0.0,
      }) {
    final createdAt = DateTime.tryParse(json['created_at'] ?? '') ??
        DateTime.now();

    // Liste endpointinde ürün, teslim aralığı vs yok → makul bir varsayım
    final pickupStart = createdAt;
    final pickupEnd = createdAt.add(const Duration(hours: 2));

    final store = json['store'] as Map<String, dynamic>?;

    return OrderItem(
      id: json['id']?.toString() ?? '',
      productName: 'Sürpriz Paket', // list endpoint ürün detayını göndermiyor
      oldPrice:
      (json['total_amount'] as num?)?.toDouble() ?? 0.0, // liste fiyatı
      newPrice:
      (json['total_amount'] as num?)?.toDouble() ?? 0.0, // şu an için aynı
      orderTime: createdAt,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupCode: json['pickup_code']?.toString() ?? '----',
      businessId: store?['id']?.toString() ?? '',
      businessName: store?['name']?.toString() ?? 'İşletme',
      businessAddress: '', // list endpoint'te yok
      businessLogo:
      'assets/logos/dailyGood_tekSaatLogo.png', // varsa placeholder asset’in
      carbonSaved: carbonPerOrder,
      isDelivered: (json['status']?.toString() ?? '') != 'pending',
    );
  }

  // ---------------------------------------------------------------------------
  // 2) POST /customer/orders ve GET /customer/orders/{id} → detay cevabı için
  // ---------------------------------------------------------------------------
  factory OrderItem.fromDetailJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at'] ?? '') ??
        DateTime.now();

    final store = json['store'] as Map<String, dynamic>?;

    final items = (json['items'] as List?) ?? [];
    final firstItem = items.isNotEmpty
        ? items.first as Map<String, dynamic>
        : <String, dynamic>{};
    final product = firstItem['product'] as Map<String, dynamic>?;

    final productName = product?['name']?.toString() ?? 'Sürpriz Paket';
    final listPrice = (product?['list_price'] as num?)?.toDouble() ??
        (json['total_amount'] as num?)?.toDouble() ??
        0.0;
    final sellingPrice = (product?['selling_price'] as num?)?.toDouble() ??
        (json['total_amount'] as num?)?.toDouble() ??
        0.0;

    // Saatler
    final deliveryDateStr = json['delivery_date']?.toString();
    final deliveryDate =
        DateTime.tryParse(deliveryDateStr ?? '') ?? createdAt;

    final startHour = product?['start_hour']?.toString(); // "09:00:00"
    final endHour = product?['end_hour']?.toString(); // "18:00:00"

    DateTime pickupStart = createdAt;
    DateTime pickupEnd = createdAt.add(const Duration(hours: 2));

    if (startHour != null && endHour != null) {
      pickupStart = _combineDateAndTime(deliveryDate, startHour);
      pickupEnd = _combineDateAndTime(deliveryDate, endHour);
    }

    return OrderItem(
      id: json['id']?.toString() ?? '',
      productName: productName,
      oldPrice: listPrice,
      newPrice: sellingPrice,
      orderTime: createdAt,
      pickupStart: pickupStart,
      pickupEnd: pickupEnd,
      pickupCode: json['pickup_code']?.toString() ?? '----',
      businessId: store?['id']?.toString() ?? '',
      businessName: store?['name']?.toString() ?? 'İşletme',
      businessAddress: store?['address']?.toString() ?? '',
      businessLogo:
      (store?['banner_image_url']?.toString() ?? '').isNotEmpty
          ? store!['banner_image_url'].toString()
          : 'assets/logos/dailyGood_tekSaatLogo.png',
      carbonSaved: 0.0, // toplamdan ayrıca geliyor
      isDelivered: (json['status']?.toString() ?? '') != 'pending',
    );
  }

  // ---------------------------------------------------------------------------
  // copyWith (zaten provider’da kullanıyorsun)
  // ---------------------------------------------------------------------------
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

// -----------------------------------------------------------------------------
// GET /customer/orders cevabının "data" alanı için wrapper
// -----------------------------------------------------------------------------
class OrderSummaryResponse {
  final int totalOrders;
  final double totalSavings;
  final double carbonFootprintSaved;
  final List<OrderItem> orders;

  OrderSummaryResponse({
    required this.totalOrders,
    required this.totalSavings,
    required this.carbonFootprintSaved,
    required this.orders,
  });

  factory OrderSummaryResponse.fromJson(Map<String, dynamic> json) {
    final totalOrders = (json['total_orders'] as num?)?.toInt() ?? 0;
    final totalSavings =
        (json['total_savings'] as num?)?.toDouble() ?? 0.0;
    final carbon = (json['carbon_footprint_saved'] as num?)?.toDouble() ?? 0.0;

    final list = (json['orders'] as List?) ?? [];
    final carbonPerOrder =
    totalOrders > 0 ? (carbon / totalOrders) : 0.0;

    final orders = list
        .map((e) => OrderItem.fromListJson(
      e as Map<String, dynamic>,
      carbonPerOrder: carbonPerOrder,
    ))
        .toList();

    return OrderSummaryResponse(
      totalOrders: totalOrders,
      totalSavings: totalSavings,
      carbonFootprintSaved: carbon,
      orders: orders,
    );
  }
}

// -----------------------------------------------------------------------------
// POST /customer/orders için item request modeli
// -----------------------------------------------------------------------------
class OrderRequestItem {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderRequestItem({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'quantity': quantity,
    'unit_price': unitPrice,
    'total_price': totalPrice,
  };
}

// -----------------------------------------------------------------------------
// Yardımcı: "2024-01-15T10:30:00+00:00" + "09:00:00" → DateTime
// -----------------------------------------------------------------------------
DateTime _combineDateAndTime(DateTime date, String hhmmss) {
  final parts = hhmmss.split(':');
  final h = int.tryParse(parts.elementAt(0)) ?? 0;
  final m = int.tryParse(parts.elementAt(1)) ?? 0;
  return DateTime(date.year, date.month, date.day, h, m);
}
