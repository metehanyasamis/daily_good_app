import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../product/presentation/widgets/product_card.dart';

class ExploreListScreen extends StatefulWidget {
  const ExploreListScreen({super.key});

  @override
  State<ExploreListScreen> createState() => _ExploreListScreenState();
}

class _ExploreListScreenState extends State<ExploreListScreen> {
  String selectedAddress = 'Nail Bey Sok.';
  String selectedSort = 'recommended';

  final List<ProductModel> products = [
    ProductModel(
      bannerImage: 'assets/images/sample_food4.jpg',
      logoImage: 'assets/images/sample_productLogo1.jpg',
      brandName: 'Sandwich City',
      packageName: 'Sürpriz Paket',
      pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
      rating: 4.7,
      distanceKm: 0.8,
      oldPrice: 270,
      newPrice: 70,
      stockLabel: 'Son 3',
    ),
    ProductModel(
      bannerImage: 'assets/images/sample_food2.jpg',
      logoImage: 'assets/images/sample_productLogo1.jpg',
      brandName: 'VGreen Dükkan',
      packageName: 'Vegan Sandviç',
      pickupTimeText: 'Bugün teslim al 14:00 - 16:00',
      rating: 4.5,
      distanceKm: 1.2,
      oldPrice: 220,
      newPrice: 55,
      stockLabel: 'Son 5',
    ),
  ];

  void _selectLocation() {
    // Lokasyon seçim ekranına yönlendirme
  }

  void _openNotifications() {
    // Bildirim sayfasına yönlendirme
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: selectedAddress,
          onLocationTap: _selectLocation,
          onNotificationsTap: _openNotifications,
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // KEŞFET
        onTabSelected: (index) {
          // tab geçiş işlemleri yapılabilir
        },
      ),
      body: Stack(
        children: [
          // 📋 Liste içeriği
          Positioned.fill(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 100), // navbar + buton için boşluk
              children: [
                // 🔍 Arama alanı
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Restoran, paket veya mekan ara',
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // 🔽 Sıralama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text('Sırala:', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(width: 6),
                      DropdownButton<String>(
                        value: selectedSort,
                        underline: const SizedBox(),
                        items: const [
                          DropdownMenuItem(value: 'recommended', child: Text('Önerilen')),
                          DropdownMenuItem(value: 'price', child: Text('Fiyata göre')),
                          DropdownMenuItem(value: 'rating', child: Text('Puana göre')),
                          DropdownMenuItem(value: 'distance', child: Text('Mesafeye göre')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedSort = value);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 🧾 Ürünler
                ...products.map((product) => ProductCard(
                  product: product,
                  onTap: () => context.push('/product-detail', extra: product),
                )),
              ],
            ),
          ),

          // 🗺 Harita Butonu (tam sağda, sağ kenarı düz)
          Positioned(
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
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
                context.push('/explore-map');
              },
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                'Harita',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
