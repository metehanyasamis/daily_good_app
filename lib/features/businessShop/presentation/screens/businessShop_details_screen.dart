import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/animated_toast.dart';
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
  @override
  Widget build(BuildContext context) {
    final business = widget.business;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: GestureDetector(
            onTap: () {
              if (context.canPop()) {
                context.pop(); // go_router güvenli geri dönüş
              } else {
                Navigator.of(context).maybePop(); // fallback
              }
            },
            child: Container(
              width: 36,
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
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.black87),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4),
            child: FavButton(
              isFav: business.isFav,
              context: context,
              size: 38,
              onToggle: () {
                setState(() => business.isFav = !business.isFav);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏞️ Banner görseli
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              child: Image.asset(
                business.businessShopBannerImage,
                width: double.infinity,
                height: 230,
                fit: BoxFit.cover,
              ),
            ),
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

            // 🗺️ Mini Harita (tam genişlik)
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
    );
  }
}
