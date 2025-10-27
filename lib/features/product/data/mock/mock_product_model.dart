import '../models/product_model.dart';

// İşletme ID'leri: '1' = Sandwich City, '2' = VGreen Dükkan, '3' = Altın Fırın, '4' = Şeker Dükkanı

final List<ProductModel> mockProducts = [
  ProductModel(
    businessId: '1', // Sandwich City (Varsayım)
    bannerImage: 'assets/images/sample_food4.jpg',
    packageName: 'Sürpriz Paket',
    pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
    oldPrice: 270.0,
    newPrice: 70.0,
    stockLabel: 'Son 3',
  ),
  ProductModel(
    businessId: '2', // VGreen Dükkan (Varsayım)
    bannerImage: 'assets/images/sample_food2.jpg',
    packageName: 'Vegan Sandviç',
    pickupTimeText: 'Bugün teslim al 14:00 - 16:00',
    oldPrice: 220.0,
    newPrice: 55.0,
    stockLabel: 'Son 5',
  ),
  ProductModel(
    businessId: '1', // Sandwich City (Varsayım)
    bannerImage: 'assets/images/sample_food3.jpg',
    packageName: 'Sürpriz Paket',
    pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
    oldPrice: 270.00,
    newPrice: 70.00,
    stockLabel: 'Son 3',
  ),
  ProductModel(
    businessId: '2', // VGreen Dükkan (Varsayım)
    bannerImage: 'assets/images/sample_food4.jpg',
    packageName: 'Vegan Sandviç',
    pickupTimeText: 'Bugün teslim al 14:00 - 16:00',
    oldPrice: 220.00,
    newPrice: 55.00,
    stockLabel: 'Son 5',
  ),
];

// Tekil Mock Product Verileri (BusinessModel içinde kullanılacak)

final ProductModel mockProductBread = ProductModel(
  businessId: '3', // Altın Fırın ID'si
  bannerImage: 'assets/images/sample_food4.jpg',
  packageName: 'Günün Ekmekleri Paketi',
  pickupTimeText: '18:00 - 20:00',
  oldPrice: 150.0,
  newPrice: 59.90,
  stockLabel: '1 Adet Kaldı',
);

final ProductModel mockProductDessert = ProductModel(
  businessId: '4', // Şeker Dükkanı ID'si (Yeni oluşturuldu)
  bannerImage: 'assets/images/sample_food3.jpg',
  packageName: 'Sürpriz Tatlı Kutusu',
  pickupTimeText: '15:30 - 17:00',
  oldPrice: 180.0,
  newPrice: 69.90,
  stockLabel: '3 Adet Kaldı',
);

final ProductModel mockProductVegan = ProductModel(
  businessId: '2', // VGreen Dükkan ID'si
  bannerImage: 'assets/images/sample_food2.jpg',
  packageName: 'Öğle Yemeği Paketi (Vegan)',
  pickupTimeText: '13:00 - 14:30',
  oldPrice: 220.0,
  newPrice: 79.90,
  stockLabel: 'Stoğu Az',
);