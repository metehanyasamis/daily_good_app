import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/floating_cart_button.dart';
import '../../data/model/businessShop_model.dart';
import '../widgets/businessShop_details_content.dart';

class BusinessShopDetailsScreen extends StatefulWidget {
  final BusinessModel business;

  const BusinessShopDetailsScreen({
    super.key,
    required this.business,
  });

  @override
  State<BusinessShopDetailsScreen> createState() =>
      _BusinessShopDetailsScreenState();
}

class _BusinessShopDetailsScreenState extends State<BusinessShopDetailsScreen> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.business.isFav;
  }

  @override
  Widget build(BuildContext context) {
    final business = widget.business;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
          slivers: [
            _header(context, business),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // 📋 İçerik
                  BusinessShopDetailsContent(
                    businessShop: business,
                    onProductTap: (product) => context.push(
                      '/product-detail',
                      extra: product,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🗺️ Mini Harita
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/sample_map.png',
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
          const FloatingCartButton(),
        ],
      ),
    );
  }

// 🔹 Header kısmı (SliverAppBar)
  Widget _header(BuildContext context, BusinessModel business) => SliverAppBar(
    pinned: true,
    expandedHeight: 230,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    leading: _roundIcon(
      icon: Icons.arrow_back_ios_new_rounded,
      onTap: () => context.pop(),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: FavButton(
          item: widget.business, // 👈 işletme modeli
        ),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(business.businessShopBannerImage, fit: BoxFit.cover),

          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              width: 74,  // radius:37 → diameter 74
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryDarkGreen, // ✅ yeşil çerçeve
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    business.businessShopLogoImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

// 🔸 Ortak ikon (ProductDetail’dakiyle birebir)
  Widget _roundIcon({required IconData icon, VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8), // ✅ birebir aynı
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, // ✅ birebir aynı
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.black87), // ✅ birebir aynı
      ),
    ),
  );
}
