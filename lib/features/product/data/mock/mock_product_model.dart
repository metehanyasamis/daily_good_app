import '../../../explore/presentation/widgets/category_filter_option.dart';
import '../../../saving/data/carbon_rules.dart';
import '../models/product_model.dart';

final List<ProductModel> mockProducts = [
  ProductModel(
    productId: 'p1',
    businessId: '1',
    businessName: 'Sandwich City',
    bannerImage: 'assets/images/sample_food4.jpg',
    packageName: 'Sürpriz Paket',
    pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
    oldPrice: 270.0,
    newPrice: 70.0,
    stockLabel: 'Son 3',
    rating: 4.7,
    distance: 0.8,
    category: CategoryFilterOption.food,
    carbonSaved: CarbonRules.getCarbon(CategoryFilterOption.food),
  ),
  ProductModel(
    productId: 'p2',
    businessId: '2',
    businessName: 'VGreen Dükkan',
    bannerImage: 'assets/images/sample_food2.jpg',
    packageName: 'Vegan Sandviç',
    pickupTimeText: 'Bugün teslim al 14:00 - 16:00',
    oldPrice: 220.0,
    newPrice: 55.0,
    stockLabel: 'Son 5',
    rating: 4.5,
    distance: 1.2,
    category: CategoryFilterOption.vegan,
    carbonSaved: CarbonRules.getCarbon(CategoryFilterOption.vegan),
  ),
  ProductModel(
    productId: 'p3',
    businessId: '2',
    businessName: 'VGreen Dükkan',
    bannerImage: 'assets/images/sample_food3.jpg',
    packageName: 'Vegan Tatlı Seçkisi',
    pickupTimeText: 'Bugün teslim al 10:00 - 12:00',
    oldPrice: 250.0,
    newPrice: 75.0,
    stockLabel: 'Son 4',
    rating: 4.8,
    distance: 1.2,
    category: CategoryFilterOption.vegan,
    carbonSaved: CarbonRules.getCarbon(CategoryFilterOption.vegan),
  ),
  ProductModel(
    productId: 'p4',
    businessId: '2',
    businessName: 'VGreen Dükkan',
    bannerImage: 'assets/images/sample_food4.jpg',
    packageName: 'Glutensiz Atıştırmalık Kutusu',
    pickupTimeText: 'Bugün teslim al 16:00 - 20:00',
    oldPrice: 180.0,
    newPrice: 60.0,
    stockLabel: 'Son 2',
    rating: 4.6,
    distance: 1.2,
    category: CategoryFilterOption.glutenFree,
    carbonSaved: CarbonRules.getCarbon(CategoryFilterOption.glutenFree),
  ),
  ProductModel(
    productId: 'p5',
    businessId: '3',
    businessName: 'Altın Fırın',
    bannerImage: 'assets/images/sample_food3.jpg',
    packageName: 'Günün Ekmekleri Paketi',
    pickupTimeText: '18:00 - 20:00',
    oldPrice: 150.0,
    newPrice: 59.9,
    stockLabel: '1 Adet Kaldı',
    rating: 4.6,
    distance: 2.1,
    category: CategoryFilterOption.bakery,
    carbonSaved: CarbonRules.getCarbon(CategoryFilterOption.bakery),
  ),
  ProductModel(
    productId: 'p6',
    businessId: '4',
    businessName: 'Şeker Dükkanı',
    bannerImage: 'assets/images/sample_food3.jpg',
    packageName: 'Sürpriz Tatlı Kutusu',
    pickupTimeText: '15:30 - 17:00',
    oldPrice: 180.0,
    newPrice: 69.9,
    stockLabel: '3 Adet Kaldı',
    rating: 4.8,
    distance: 0.5,
    category: CategoryFilterOption.bakery,
    carbonSaved: CarbonRules.getCarbon(CategoryFilterOption.bakery),
  ),
];


ProductModel? findProductByName(String name) {
  try {
    return mockProducts.firstWhere(
          (p) => p.packageName.toLowerCase() == name.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
}