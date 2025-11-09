import 'order_model.dart';

final mockOrders = [
  OrderItem(
    id: generateOrderNumber(),
    productName: "Sürpriz Paket 1",
    oldPrice: 270,
    newPrice: 70,
    orderTime: DateTime.now(),
    pickupStart: DateTime.now().add(const Duration(hours: 5)),
    pickupEnd: DateTime.now().add(const Duration(hours: 6)),
    pickupCode: generatePickupCode(),
    businessName: "Sandwich City",
    businessAddress: "Terzi Bey Sokak No:46 Kadıköy",
    businessLogo: "assets/images/sample_food.jpg",
    carbonSaved: 0.4, // ✅ eklendi
  ),
  OrderItem(
    id: generateOrderNumber(),
    productName: "Sürpriz Paket 2",
    oldPrice: 350,
    newPrice: 110,
    orderTime: DateTime.now().subtract(const Duration(days: 15)),
    pickupStart: DateTime.now().add(const Duration(hours: 3)),
    pickupEnd: DateTime.now().add(const Duration(hours: 4)),
    pickupCode: generatePickupCode(),
    businessName: "Sandwich City",
    businessAddress: "Terzi Bey Sokak No:46 Kadıköy",
    businessLogo: "assets/images/sample_food2.jpg",
    carbonSaved: 0.5, // ✅ eklendi
  ),
];
