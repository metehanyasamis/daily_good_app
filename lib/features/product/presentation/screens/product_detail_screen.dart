import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../business/model/business_model.dart';
import '../../../product/presentation/widgets/product_card.dart'; // ProductModel

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ========= SCROLLABLE CONTENT =========
          CustomScrollView(
            slivers: [
              // Kapak + overlay öğeler
              SliverAppBar(
                pinned: true,
                expandedHeight: 240,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                leading: _roundedIcon(
                  context,
                  Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: const Text(
                  '',
                  style: TextStyle(color: Colors.black),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _roundedIcon(
                      context,
                      Icons.favorite_border,
                      onTap: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        p.bannerImage,
                        fit: BoxFit.cover,
                      ),
                      // Sol üst "Son x" etiketi
                      Positioned(
                        top: 16,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Text(
                            p.stockLabel,
                            style: TextStyle(
                              color: AppColors.primaryDarkGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      // Dairesel logo
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.asset(
                              p.logoImage,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Başlık kartı
              SliverToBoxAdapter(
                child: _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Üst satır: paket adı + fiyatlar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.packageName,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        size: 14,
                                        color: AppColors.primaryDarkGreen),
                                    const SizedBox(width: 4),
                                    Text(
                                      p.rating.toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text('•',
                                        style: TextStyle(fontSize: 13)),
                                    const SizedBox(width: 10),
                                    Icon(Icons.place,
                                        size: 14,
                                        color: AppColors.primaryDarkGreen),
                                    const SizedBox(width: 4),
                                    Text('${p.distanceKm.toStringAsFixed(1)} km',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  p.pickupTimeText,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${p.oldPrice.toStringAsFixed(0)} tl',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${p.newPrice.toStringAsFixed(0)} tl',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.primaryDarkGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Bu pakette seni ne bekliyor?
              SliverToBoxAdapter(
                child: _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Bu pakette seni ne bekliyor?'),
                      const SizedBox(height: 8),
                      Text(
                        'Lezzetli sandviçler, tek porsiyonluk tatlılar, atıştırmalık kokteyller',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _thinDivider(),
                      const SizedBox(height: 12),
                      _sectionTitle('Bilmeniz gerekenler'),
                      const SizedBox(height: 8),
                      _bullet(
                          'Mobil Alım ve Teslimat Kuralları',
                          icon: Icons.campaign_rounded),
                      _dot('Mobil Alım Zorunluluğu: Bu indirimler sadece mobil uygulama üzerinden yapılan alımlarda geçerlidir.'),
                      _dot('Teslimat saat aralığı: 15:30 – 17:00.'),
                    ],
                  ),
                ),
              ),

              // Teslim alma bilgileri
              SliverToBoxAdapter(
                child: _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Teslim alma bilgileri'),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.storefront_outlined,
                              color: AppColors.primaryDarkGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => context.go(
                                    '/business-detail',
                                    extra: BusinessModel(
                                      name: 'Sandwich City',
                                      address: 'Terzi Bey sokak no : 46 / Kadıköy',
                                      image: 'assets/images/sample_productLogo1.jpg',
                                      rating: 4.7,
                                      distance: 0.8,
                                      workingHours: '08:00 - 16:00',
                                      products: [widget.product],
                                    ),
                                  ),
                                  child: const Text(
                                    'Sandwich City',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF22823B), // yeşilimsi link etkisi
                                      decoration: TextDecoration.underline, // opsiyonel link görünümü
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: Colors.grey.shade600),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // İşletme değerlendirme (basit)
              SliverToBoxAdapter(
                child: _whiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _sectionTitle('İşletme Değerlendirme'),
                          const SizedBox(width: 6),
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.grey.shade500),
                          const Spacer(),
                          Icon(Icons.star,
                              size: 16, color: AppColors.primaryDarkGreen),
                          const SizedBox(width: 4),
                          const Text('4.7 (70+)'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ratingRow('Servis', 4.5),
                      _ratingRow('Ürün Miktarı', 5.0),
                      _ratingRow('Ürün Lezzeti', 5.0),
                      _ratingRow('Ürün Çeşitliliği', 4.0),
                    ],
                  ),
                ),
              ),

              // Harita görseli (placeholder)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/sample_map.png',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // ========= BOTTOM BAR =========
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  // Miktar
                  _qtyButton(
                    icon: Icons.remove,
                    onTap: () => setState(() => qty = math.max(1, qty - 1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  _qtyButton(
                    icon: Icons.add,
                    onTap: () => setState(() => qty += 1),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Sepete ekle / “Benim için tut” aksiyonu
                      },
                      child: Container(
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3E8D4E), Color(0xFF7EDC8A)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: const Text(
                          'Benim için tut',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- helpers ----
  Widget _roundedIcon(BuildContext context, IconData icon,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        width: 38,
        height: 38,
        child: Icon(icon, color: Colors.black87, size: 18),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  Widget _thinDivider() => Container(
    height: 1,
    color: Colors.grey.withOpacity(0.2),
  );

  Widget _bullet(String text, {IconData icon = Icons.circle}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Colors.black87, size: 18),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
    ],
  );

  Widget _dot(String text) => Padding(
    padding: const EdgeInsets.only(left: 26, top: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  ', style: TextStyle(height: 1.35)),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 14, height: 1.35)),
        ),
      ],
    ),
  );

  Widget _ratingRow(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        SizedBox(width: 130, child: Text(label)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 5.0,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primaryDarkGreen,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(value.toStringAsFixed(1)),
      ],
    ),
  );

  Widget _qtyButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
