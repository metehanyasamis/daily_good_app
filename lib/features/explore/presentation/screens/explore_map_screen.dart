import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../business/model/business_model.dart';
import '../../../business/presentation/widgets/business_details_content.dart';
import '../../../product/presentation/widgets/product_card.dart';

class ExploreMapScreen extends StatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  State<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends State<ExploreMapScreen> {
  // Mock veriler
  final List<Map<String, dynamic>> _shops = [
    {
      'id': '1',
      'name': 'Sandwich City',
      'pickupTime': '15:30 - 17:00',
      'rating': 4.7,
      'distance': 0.8,
      'address': 'Terzi Bey Sokak no: 46 / Kadıköy',
    },
    {
      'id': '2',
      'name': 'VGreen Dükkan',
      'pickupTime': '14:00 - 16:00',
      'rating': 4.5,
      'distance': 1.2,
      'address': 'Moda Cd. no: 12 / Kadıköy',
    },
  ];

  String? _selectedShopId;

  Map<String, dynamic>? get _selectedShop {
    if (_selectedShopId == null) return null;
    return _shops.firstWhere((s) => s['id'] == _selectedShopId, orElse: () => {});
  }

  void _onPinTap(String shopId) {
    setState(() {
      _selectedShopId = shopId;
    });
  }

  void _onCardTap() {
    final shop = _selectedShop;
    if (shop != null) {
      final business = BusinessModel(
        name: shop['name'] ?? 'İşletme Adı Yok',
        address: shop['address'] ?? 'Adres bilgisi yok',
        image: shop['image'] ?? 'assets/images/shop1.jpg',
        rating: shop['rating'] ?? 4.5,
        distance: shop['distance'] ?? 0.8,
        workingHours: shop['workingHours'] ?? '08:00 - 16:00',
        products: [
          ProductModel(
            bannerImage: 'assets/images/sample_food4.jpg',
            logoImage: 'assets/images/sample_productLogo1.jpg',
            brandName: shop['name'] ?? 'İşletme Adı',
            packageName: 'Sürpriz Paket',
            pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
            rating: 4.7,
            distanceKm: 0.8,
            oldPrice: 270,
            newPrice: 70,
            stockLabel: 'Son 3',
          ),
          ProductModel(
            bannerImage: 'assets/images/sample_food4.jpg',
            logoImage: 'assets/images/sample_productLogo1.jpg',
            brandName: shop['name'] ?? 'İşletme Adı',
            packageName: 'Sürpriz Paket',
            pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
            rating: 4.7,
            distanceKm: 0.8,
            oldPrice: 270,
            newPrice: 70,
            stockLabel: 'Son 3',
          ),
          ProductModel(
            bannerImage: 'assets/images/sample_food4.jpg',
            logoImage: 'assets/images/sample_productLogo1.jpg',
            brandName: shop['name'] ?? 'İşletme Adı',
            packageName: 'Sürpriz Paket',
            pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
            rating: 4.7,
            distanceKm: 0.8,
            oldPrice: 270,
            newPrice: 70,
            stockLabel: 'Son 3',
          ),
          ProductModel(
            bannerImage: 'assets/images/sample_food4.jpg',
            logoImage: 'assets/images/sample_productLogo1.jpg',
            brandName: shop['name'] ?? 'İşletme Adı',
            packageName: 'Sürpriz Paket',
            pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
            rating: 4.7,
            distanceKm: 0.8,
            oldPrice: 270,
            newPrice: 70,
            stockLabel: 'Son 3',
          ),
        ],
      );

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 0.95,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: controller,
              child: BusinessDetailContent(business: business),
            ),
          ),
        ),
      );
    }
  }



  final dummyProducts = [
    ProductModel(
      logoImage: 'assets/images/sample_productLogo1.jpg',
      bannerImage: 'assets/images/sample_food1.jpg',
      brandName: 'Sandwich City',
      packageName: 'Sürpriz Paket',
      pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
      rating: 4.7,
      distanceKm: 0.8,
      oldPrice: 270,
      newPrice: 70,
      stockLabel: 'Son 3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: 'Nail Bey Sok.',
          onLocationTap: () {
            // Lokasyon seçimi
          },
          onNotificationsTap: () {
            // Bildirim ekranı
          },
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTabSelected: (index) {
          // Tab geçişleri
        },
      ),
      body: Stack(
        children: [
          // Harita yerine mock görsel
          Positioned.fill(
            child: Image.asset(
              'assets/images/sample_map.png',
              fit: BoxFit.cover,
            ),
          ),

          // Mock pinler (ikon ile)
          Positioned(
            left: 60,
            top: 220,
            child: GestureDetector(
              onTap: () => _onPinTap('1'),
              child: Icon(Icons.location_on, color: AppColors.primaryDarkGreen, size: 36),
            ),
          ),
          Positioned(
            left: 180,
            top: 350,
            child: GestureDetector(
              onTap: () => _onPinTap('2'),
              child: Icon(Icons.location_on, color: AppColors.primaryDarkGreen, size: 36),
            ),
          ),

          // Arama kutusu
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: SafeArea(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Restoran, paket veya mekan ara',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Alt kart: pin seçildiğinde göster
          if (_selectedShop != null && _selectedShop!['name'] != null)
            Positioned(
              bottom: kBottomNavigationBarHeight + 80,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: _onCardTap,
                child: _BusinessCard(shop: _selectedShop!),
              ),
            ),

          // Liste butonu
          Positioned(
            right: 0,
            bottom: kBottomNavigationBarHeight + 16,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkGreen,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topRight: Radius.zero,
                    bottomRight: Radius.zero,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () {
                context.push('/explore-list');
              },
              icon: const Icon(Icons.list, color: Colors.white),
              label: const Text(
                'Liste',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Alt kart widget
class _BusinessCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  const _BusinessCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: AssetImage('assets/images/sample_productLogo1.jpg'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop['name'] ?? 'İşletme adı yok',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    shop['pickupTime'] != null
                        ? 'Bugün teslim al ${shop['pickupTime']}'
                        : 'Bugün teslim al',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 28),
          ],
        ),
      ),
    );
  }
}
