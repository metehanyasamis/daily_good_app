import 'order_model.dart';
import '../../businessShop/data/mock/mock_businessShop_model.dart'; // 🆕 EKLENDİ

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

    businessId: mockBusinessList[0].id,                     // 🆕 EKLENDİ
    businessName: mockBusinessList[0].name,
    businessAddress: mockBusinessList[0].address,
    businessLogo: mockBusinessList[0].businessShopLogoImage,

    carbonSaved: 0.4,
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

    businessId: mockBusinessList[0].id,                     // 🆕 EKLENDİ (aynı işletme)
    businessName: mockBusinessList[0].name,
    businessAddress: mockBusinessList[0].address,
    businessLogo: mockBusinessList[0].businessShopLogoImage,

    carbonSaved: 0.5,
  ),
];
