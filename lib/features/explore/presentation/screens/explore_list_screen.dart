import 'package:daily_good/features/product/data/mock/mock_product_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_bottom_nav_bar.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../product/data/models/product_model.dart';
import '../../../product/presentation/widgets/product_card.dart' hide ProductModel;

class ExploreListScreen extends StatefulWidget {
  const ExploreListScreen({super.key});

  @override
  State<ExploreListScreen> createState() => _ExploreListScreenState();
}

class _ExploreListScreenState extends State<ExploreListScreen> {
  String selectedAddress = 'Nail Bey Sok.';
  String selectedSort = 'recommended';
  final List<ProductModel> sampleExploreProducts = mockProducts;

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
                ...sampleExploreProducts.map((product) => ProductCard(
                  product: product,
                  onTap: () => context.push('/product-detail', extra: product),
                )),
              ],
            ),
          ),

          // 🗺 Harita Butonu (tam sağda, sağ kenarı düz)
          Positioned(
            right: 0,
          bottom: (MediaQuery.of(context).padding.bottom > 0
          ? MediaQuery.of(context).padding.bottom
              : 20) + 80, // ✅ Alt nav bar üstüne tam oturur
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
