import '../../../product/data/mock/mock_product_model.dart';
import '../model/businessShop_model.dart';

final List<BusinessModel> mockBusinessList = [
  BusinessModel(
    id: '1',
    name: 'Sandwich City',
    address: 'Nail Bey Sok. No: 10 / Beşiktaş',
    businessShopLogoImage: 'assets/images/sample_productLogo1.jpg',
    businessShopBannerImage: 'assets/images/shop1.jpg',
    rating: 4.7,
    distance: 0.8,
    workingHours: '15:30 - 17:00',
    products: mockProducts.where((p) => p.businessId == '1').toList(),
  ),
  BusinessModel(
    id: '2',
    name: 'VGreen Dükkan',
    address: 'Moda Cd. No: 12 / Kadıköy',
    businessShopLogoImage: 'assets/images/shop1.jpg',
    businessShopBannerImage: 'assets/images/shop1.jpg',
    rating: 4.5,
    distance: 1.2,
    workingHours: '14:00 - 16:00',
    products: mockProducts.where((p) => p.businessId == '2').toList(),
  ),
  BusinessModel(
    id: '3',
    name: 'Altın Fırın',
    address: 'Bağdat Cd. No: 55 / Erenköy',
    businessShopLogoImage: 'assets/images/sample_productLogo1.jpg',
    businessShopBannerImage: 'assets/images/shop2.jpg',
    rating: 4.8,
    distance: 0.7,
    workingHours: '18:00 - 20:00',
    products: mockProducts.where((p) => p.businessId == '3').toList(),
  ),
  BusinessModel(
    id: '4',
    name: 'Şeker Dükkanı',
    address: 'Şair Nedim Cd. No: 20 / Beşiktaş',
    businessShopLogoImage: 'assets/images/sample_productLogo1.jpg',
    businessShopBannerImage: 'assets/images/shop2.jpg',
    rating: 4.5,
    distance: 1.2,
    workingHours: '15:30 - 17:00',
    products: mockProducts.where((p) => p.businessId == '4').toList(),
  ),
];

BusinessModel? findBusinessById(String id) {
  try {
    return mockBusinessList.firstWhere((b) => b.id == id);
  } catch (e) {
    return null;
  }
}
