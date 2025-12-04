import '../../../product/data/models/product_model.dart';
import '../../../explore/presentation/widgets/category_filter_option.dart'; // Category importu

class BusinessModel {
  final String id;
  final String name;
  final String address;
  // 🔥 businessShopLogoImage, ProductStoreModel'deki bannerImageUrl'a karşılık gelebilir.
  // Model isimlerini API'ya göre sadeleştiriyorum.
  final String? businessShopLogoImage;
  final String? businessShopBannerImage;
  final double rating;
  final double distance;
  final String workingHours;
  final List<ProductModel>? products; // Artık zorunlu değil
  final double latitude;
  final double longitude;
  final bool isFavorite;

  BusinessModel({
    required this.id,
    required this.name,
    required this.address,
    required this.businessShopLogoImage, // Optional hale getirildi
    required this.businessShopBannerImage, // Optional hale getirildi
    required this.rating, // Zorunlu
    required this.distance, // Zorunlu
    required this.workingHours, // Zorunlu
    this.products, // Zorunlu değil
    this.latitude = 41.0082,
    this.longitude = 28.9784,
    this.isFavorite = false,
  });

  // 🔥 toProductStoreModel Adapter'ı:
  // BusinessModel'i, ProductModel'in beklediği ProductStoreModel'e dönüştürür.
  ProductStoreModel toProductStoreModel() {
    // BrandModel'i BusinessModel'den oluşturmanın yolu olmadığı için
    // varsayılan bir BrandModel kullanmalıyız.
    // **Eğer BusinessModel içinde BrandModel yoksa, API'nız BusinessModel'i yanlış tasarlamış demektir.**
    // Geçici olarak bir BrandModel varsayımı yapıyorum.
    final defaultBrand = BrandModel(id: 'b', name: 'Unknown Brand');

    return ProductStoreModel(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      bannerImageUrl: businessShopBannerImage,
      address: address,
      isFavorite: isFavorite,
      distanceKm: distance,
      brand: defaultBrand, // 🔥 Brand bilgisi BusinessModel'de eksik görünüyor.
      rating: rating,
      workingHours: workingHours,
    );
  }
}