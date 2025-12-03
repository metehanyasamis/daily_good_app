import '../../../explore/presentation/widgets/category_filter_option.dart';
import '../../../product/data/models/product_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart'; // Brand ve Store için gerekli olabilir

// GET /customer/favorites/products yanıtındaki tek bir öğeyi temsil eder
class FavoriteProductResponseModel {
  final String id; // Favori ID'si
  final String productId; // Ürünün ID'si
  final ProductDetail product; // Ürün detayları

  FavoriteProductResponseModel({
    required this.id,
    required this.productId,
    required this.product,
  });

  factory FavoriteProductResponseModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProductResponseModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      product: ProductDetail.fromJson(json['product'] as Map<String, dynamic>),
    );
  }

  // Domain modeline (ProductModel) dönüşüm
  // 🔥 HATA GİDERİLDİ: ProductModel'in yeni zorunlu alanlarına göre eşleştirme yapıldı.
  ProductModel toDomain() {

    // ProductDetail, ProductModel'e dönüşürken eksik olan alanlar için varsayılan değerler
    const defaultCategory = CategoryFilterOption.all;

    // StoreInProductDetail'ı BusinessModel'e dönüştür (eğer ProductModel'in ihtiyacı buysa)
    final BusinessModel storeModel = product.store.toDomain();


    return ProductModel(
      // ProductModel'in muhtemelen yeni zorunlu alanları (Hata listesine göre):
      id: product.id,
      name: product.name,
      listPrice: product.listPrice.toDouble(),
      salePrice: product.salePrice.toDouble(),
      stock: product.stock,
      imageUrl: product.imageUrl,
      store: storeModel, // BusinessModel (Store) nesnesine dönüştürülmüş hali

      // Tarih/Saat Alanları (Datetime.parse ile dönüştürülmesi gerekebilir, şimdilik String olarak varsayıyorum)
      startHour: product.startHour,
      endHour: product.endHour,
      startDate: product.startDate,
      endDate: product.endDate,

      // Diğer zorunlu alanlar (Varsayılan veya Yer Tutucu):
      createdAt: DateTime.now(), // API'dan gelmiyorsa varsayılan atandı
      description: product.description, // Açıklama eklendi

      // Geleneksel UI alanları (API'dan gelmiyorsa varsayılan atandı)
      rating: 4.5,
      distance: 2.1,
      category: defaultCategory,
      carbonSaved: 0.0,
      isFavorite: true,
    );
  }
}


// Alt detay modelleri (API yanıtına göre)

class ProductDetail {
  final String id;
  final String name;
  final int listPrice;
  final int salePrice;
  final int stock;
  final String imageUrl;
  final String description;
  final String startHour;
  final String endHour;
  final String startDate;
  final String endDate;
  final StoreInProductDetail store;
  final String createdAt; // Favori listesi hatasında bu da isteniyordu

  ProductDetail({
    required this.id, required this.name, required this.listPrice,
    required this.salePrice, required this.stock, required this.imageUrl,
    required this.description, required this.startHour, required this.endHour,
    required this.startDate, required this.endDate, required this.store,
    required this.createdAt, // Eklendi
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) => ProductDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    listPrice: json['list_price'] as int,
    salePrice: json['sale_price'] as int,
    stock: json['stock'] as int,
    imageUrl: json['image_url'] as String,
    description: json['description'] as String,
    startHour: json['start_hour'] as String,
    endHour: json['end_hour'] as String,
    startDate: json['start_date'] as String,
    endDate: json['end_date'] as String,
    store: StoreInProductDetail.fromJson(json['store'] as Map<String, dynamic>),
    createdAt: json['created_at'] as String, // Eklendi
  );
}

class StoreInProductDetail {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String latitude;
  final String longitude;
  final String bannerImage;
  final BrandInProductDetail brand;

  StoreInProductDetail({
    required this.id, required this.name, required this.address,
    required this.phone, required this.latitude, required this.longitude,
    required this.bannerImage, required this.brand
  });

  factory StoreInProductDetail.fromJson(Map<String, dynamic> json) => StoreInProductDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    phone: json['phone'] as String,
    latitude: json['latitude'] as String,
    longitude: json['longitude'] as String,
    bannerImage: json['banner_image'] as String,
    brand: BrandInProductDetail.fromJson(json['brand'] as Map<String, dynamic>),
  );

  // BusinessModel'e dönüştürme metodu (ProductModel'de kullanmak için)
  BusinessModel toDomain() {
    return BusinessModel(
      id: id,
      name: name,
      address: address,
      phone: phone,
      latitude: double.tryParse(latitude) ?? 0.0,
      longitude: double.tryParse(longitude) ?? 0.0,
      bannerImage: bannerImage,
      // Brand'i de BusinessModel'e aktarmanız gerekebilir,
      // ancak BusinessModel'in yapısını bilmediğim için şimdilik sadece temel alanları eşleştiriyorum.
    );
  }
}

class BrandInProductDetail {
  final String id;
  final String name;
  final String logoUrl;

  BrandInProductDetail({required this.id, required this.name, required this.logoUrl});
  factory BrandInProductDetail.fromJson(Map<String, dynamic> json) => BrandInProductDetail(
    id: json['id'] as String,
    name: json['name'] as String,
    logoUrl: json['logo_url'] as String,
  );
}