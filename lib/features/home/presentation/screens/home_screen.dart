import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../location/presentation/screens/location_picker_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedAddress = 'Nail Bey Sok.';
  int selectedCategoryIndex = 0;

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null && result is String) {
      setState(() => selectedAddress = result);
    }
  }

  void _openNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  final List<String> categories = [
    'Tümü',
    'Yemek',
    'Fırın &\nPastane',
    'Kahvaltı',
    'Market &\nManav',
    'Vejetaryen',
    'Vegan',
    'Glutensiz',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 👈 arka plan sabit
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: CustomHomeAppBar(
          address: selectedAddress,
          onLocationTap: _selectLocation,
          onNotificationsTap: _openNotifications,
        ),
      ),

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // 🔹 Banner alanı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 8), // ✅ yan padding’leri kaldırdık
              child: _BannerSlider(), // 👈 yeni widget
            ),
          ),

          // 🔹 Kategori bar
          SliverPersistentHeader(
            pinned: true,
            delegate: CategoryHeaderDelegate(
              categories: categories,
              selectedIndex: selectedCategoryIndex,
              onSelected: (index) {
                setState(() => selectedCategoryIndex = index);
              },
            ),
          ),
        ],

        // 🔹 Ürün listesi
        body: const _ProductSections(),
      ),
    );
  }
}

class CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  CategoryHeaderDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {




    // 1. Dinamik Hesaplamalar (Shrink Factor)
    final double maxScrollExtent = maxExtent - minExtent;
    final double shrinkFactor = (maxScrollExtent > 0)
        ? (shrinkOffset / maxScrollExtent).clamp(0.0, 1.0)
        : 0.0;

    // Kapsayıcı yüksekliği de küçülmeli
    final double currentContainerHeight = lerpDouble(maxExtent, minExtent, shrinkFactor)!;



    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final bool isSelected = selectedIndex == index;
          final String category = categories[index];

          // 3. isSelected'a BAĞLI OLAN DİNAMİK HESAPLAMALAR BURAYA TAŞINDI:
          final double startIconSize = isSelected ? 70 : 62;
          final double endIconSize = startIconSize * 0.70; // %30 küçülmüş boyut
          final double currentIconSize = lerpDouble(startIconSize, endIconSize, shrinkFactor)!;

          // DİNAMİK METİN POZİSYONU HESAPLAMASI (Transform.translate yerine)
          // Seçili değilken dikey merkezde kalmalı (0.0)
          // Seçiliyken, yeşil alanın ortasına çekilmeli (örneğin -10.0 birim yukarı)
          final double verticalShift = isSelected
              ? lerpDouble(-10.0, -2.0, shrinkFactor)! // Büyükken -10, küçükken -2 (yeşilin ortası)
              : 0.0; // Seçili değilken hep aynı yerde kalsın

// itemBuidler metodu içinde kullanılacak kısım
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container( // Güvenli alan ve margin için Container kullanıldı
              width: 78,
              height: currentContainerHeight, // maxExtent (120) ile minExtent (110.0) arasında değişir
              margin: const EdgeInsets.only(right: 12),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 🔹 Yeşil oval arka plan (AnimatedAlign)
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    // Seçili değilken yeşil alanın küçülmüş kapsayıcının (Container) alt kenarında kalmasını sağlar.
                    alignment: isSelected
                    // ⚠️ DÜZELTME 1: Seçiliyken (BÜYÜK durum) 0.5'ten 0.02'ye küçülsün
                        ? Alignment.lerp(
                      const Alignment(0, 0.5), // Büyükken başlangıç konumu (0.5)
                      const Alignment(0, 0.0), // Küçükken bitiş konumu (0.02)
                      shrinkFactor,
                    )!

                    // Seçili değilken: Görünmez alanın altta tutulması (Orijinal hali)
                        : Alignment.lerp(
                      const Alignment(0, 1.3), // Orijinal: Görünmez alan daha aşağıda başlar
                      Alignment.bottomCenter, // Orijinal: Küçülünce tam alta iner (1.0)
                      shrinkFactor,
                    )!,
                    child: Opacity(
                      opacity: isSelected ? 1.0 : 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        width: lerpDouble(72, 72 * 0.80, shrinkFactor)!,
                        height: isSelected ? lerpDouble(94, 94 * 0.60, shrinkFactor)! : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDarkGreen,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50), // Diğer köşeleri korumak için, eğer istiyorsanız
                            bottomLeft: Radius.circular(30), // orijinal değerleri bırakın
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: AppColors.primaryDarkGreen.withValues(alpha: .15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                      ),
                    ),
                  ),

                  // 🔹 YENİ: İkon ve Metin Bloğu (Transform yerine Align ile konumlandırıldı)
                  Align(
                    // Metin ve ikon bloğunun dikey konumu:
                    alignment: isSelected
                        ? Alignment.topCenter // Seçiliyken yukarıda (yeşil alanın ortası için)
                    // Seçili değilken (shrinkFactor ile): Ortaya yakın (0.0) pozisyondan,
                    // küçükken daha üste (Alignment(0, -0.2)) hareket eder
                        : Alignment.lerp(
                      const Alignment(0, -0.4), // Statik (Büyük) haldeyken dikey ortada
                      const Alignment(0, -0.8), // Küçük haldeyken hafif yukarıda
                      shrinkFactor,
                    )!,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Sadece içeriği kadar yer kapla
                      children: [
                        // Kategori İkonu
                        AnimatedContainer(

                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: currentIconSize,
                          height: currentIconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/${_iconNameFor(category)}.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // İki satırlı metin için minimum boşluk
                        SizedBox(height: lerpDouble(4, 1, shrinkFactor)),

                        // Kategori Yazısı (Metin kayması çözüldü)
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: lerpDouble(13, 11, shrinkFactor),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.black.withOpacity(0.9),
                          ),
                          // Transform.translate tamamen KALDIRILDI
                          child: Text(category, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 EKSİK KATEGORİLER EKLENDİ
  String _iconNameFor(String category) {
    final cleanCategory = category.replaceAll('\n', '');

    switch (cleanCategory) {
      case 'Tümü':
        return 'all';
      case 'Yemek':
        return 'food';
      case 'Fırın & Pastane':
        return 'bakery';
      case 'Kahvaltı':
        return 'breakfast';
      case 'Market & Manav':
        return 'market';
      case 'Vejetaryen': // Türkçe yazımına dikkat ederek dosya adını belirledim
        return 'vegetarian';
      default:
        return 'food';
    }
  }

  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 110;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _ProductSections extends StatelessWidget {
  const _ProductSections({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        top: 0,
        bottom: kBottomNavigationBarHeight + 24, // 🔥 ekstra kaydırma alanı
      ),      children: const [
        SectionTitle(title: "Hemen Yanımda"),
        SampleProductList(),
        SectionTitle(title: "Son Şans"),
        SampleProductList(),
        SectionTitle(title: "Yeni Mekanlar"),
        SampleProductList(),
        SectionTitle(title: "Bugün Al"),
        SampleProductList(),
        SectionTitle(title: "Yarın Al"),
        SampleProductList(),
        SectionTitle(title: "Favorilerim"),
        SampleProductList(),
        SizedBox(height: 32),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ],
      ),
    );
  }
}

class SampleProductList extends StatelessWidget {
  const SampleProductList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ProductModel> sampleProducts = [
      ProductModel(
        bannerImage: 'assets/images/sample_food3.jpg',
        logoImage: 'assets/images/sample_productLogo1.jpg',
        brandName: 'Sandwich City',
        packageName: 'Sürpriz Paket',
        pickupTimeText: 'Bugün teslim al 15:30 - 17:00',
        rating: 4.7,
        distanceKm: 0.8,
        oldPrice: 270.00,
        newPrice: 70.00,
        stockLabel: 'Son 3',
      ),
      ProductModel(
        bannerImage: 'assets/images/sample_food4.jpg',
        logoImage: 'assets/images/sample_productLogo1.jpg',
        brandName: 'VGreen Dükkan',
        packageName: 'Vegan Sandviç',
        pickupTimeText: 'Bugün teslim al 14:00 - 16:00',
        rating: 4.5,
        distanceKm: 1.2,
        oldPrice: 220.00,
        newPrice: 55.00,
        stockLabel: 'Son 5',
      ),
    ];

    return SizedBox(
      height: 240, // kart yüksekliği
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: sampleProducts.length,
        itemBuilder: (context, index) {
          final product = sampleProducts[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.82, // 🔹 genişliği biraz küçült
            margin: EdgeInsets.only(
              right: index == sampleProducts.length - 1 ? 0 : 1,
            ),
            child: ProductCard(product: product,
              onTap: () => context.push('/product-detail', extra: product),
            ),
          );
        },
      ),
    );
  }
}

class _BannerSlider extends StatefulWidget {
  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  final PageController _controller = PageController(viewportFraction: 0.96);
  int _currentIndex = 0;

  final List<String> banners = [
    'assets/images/banner_veggie.jpg',
    'assets/images/banner_food2.jpg',
    'assets/images/banner_food3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: 180, // Banner yüksekliği
          width: screenWidth,
          child: PageView.builder(
            controller: _controller,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_controller.position.haveDimensions) {
                    scale = (_controller.page! - index).abs().clamp(0.0, 1.0);
                    scale = 1 - (scale * 0.08); // Hafif zoom efekti
                  }

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4), // kenar boşluğu
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          banners[index],
                          fit: BoxFit.cover,
                          width: screenWidth,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (index) {
            final bool isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 18 : 6,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryDarkGreen
                    : AppColors.primaryLightGreen.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
