import '../../../product/data/mock/mock_product_model.dart';
import '../model/businessShop_model.dart';

final List<BusinessModel> mockBusinessList = [
  // 1. İşletme: Sandwich City (Yeni eklendi)
  BusinessModel(
    id: '1',
    name: 'Sandwich City',
    address: 'Nail Bey Sok. No: 10 / Beşiktaş',
    businessShopLogoImage: 'assets/images/sample_productLogo1.jpg',
    rating: 4.7,
    distance: 0.8,
    workingHours: '15:30 - 17:00',
    // Bu liste, mockProducts listesinin filtrelemiş halini temsil eder.
    products: [mockProducts[0], mockProducts[2]],
  ),

  // 2. İşletme: VGreen Dükkan
  BusinessModel(
    id: '2',
    name: 'VGreen Dükkan',
    address: 'Moda Cd. no: 12 / Kadıköy',
    businessShopLogoImage: 'assets/images/shop1.jpg', // Farklı logo kullandım
    rating: 4.5,
    distance: 1.2,
    workingHours: '14:00 - 16:00',
    products: [mockProducts[1], mockProducts[3], mockProductVegan],
  ),

  // 3. İşletme: Altın Fırın (Fırın)
  BusinessModel(
    id: '3',
    name: 'Altın Fırın',
    address: 'Bağdat Cd. No: 55 / Erenköy',
    businessShopLogoImage: 'assets/images/sample_productLogo1.jpg',
    rating: 4.8,
    distance: 0.7,
    workingHours: '18:00 - 20:00',
    products: [mockProductBread],
  ),

  // 4. İşletme: Şeker Dükkanı (Yeni eklendi - Tatlıcı)
  BusinessModel(
    id: '4',
    name: 'Şeker Dükkanı',
    address: 'Şair Nedim Cd. No: 20 / Beşiktaş',
    businessShopLogoImage: 'assets/images/sample_productLogo1.jpg',
    rating: 4.5,
    distance: 1.2,
    workingHours: '15:30 - 17:00',
    products: [mockProductDessert],
  ),
];


BusinessModel? findBusinessById(String id) {
  try {
    return mockBusinessList.firstWhere((business) => business.id == id);
  } catch (e) {
    // ID bulunamazsa null döner
    return null;
  }
}