import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../../core/widgets/product_bottom_bar.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int qty = 1;
  bool isFav = false;
  bool expanded = false;

  // 🔹 stok limiti ("Son 3" -> max 3)
  int get maxQty {
    final stockText = widget.product.stockLabel;
    final match = RegExp(r'\d+').firstMatch(stockText);
    return match != null ? int.parse(match.group(0)!) : 99;
  }

  /*
  static const String _knowMoreFull = '''
🔔 Mobil Alım ve Teslimat Kuralları
📱 Mobil Alım Zorunluluğu: Bu indirimler sadece mobil uygulama üzerinden yapılan alımlarda geçerlidir. Direkt mağazadan alımlarda bu indirim uygulanmamaktadır.
⏰ Teslimat Saat Aralığı: Ürünü, siparişinizde belirtilen saat aralığında mağazadan teslim alabilirsiniz.
↩️ İptal Hakkı: Siparişinizi teslim alma zamanına 3 saate kadar iptal etme hakkınız bulunmaktadır.
❌ Teslim Almama Durumu: Belirtilen zaman diliminde teslim alınmayan ürünler için, işletmenin bu ürünü başkasına satma hakkı bulunmaktadır (iade yapılmaz).

🎁 Paket İçeriği ve Güvenlik
💚 Sürprizleri Seviyoruz! Her paket birbirinden farklıdır. Gün sonunda gıda israfını önlemek amacıyla, yenilebilir durumda kalan ürünlerle her seferinde yeni bir sürpriz hazırlanır.
⚠️ Önemli Alerji Bilgisi: Alerjiniz veya özel bir isteğiniz varsa, paketi teslim almadan önce lütfen işletmeye danışmanızı şiddetle öneririz.

🌱 Doğa Dostu Hatırlatma
🌿 Çantanızı Getirin: Sürpriz paketinizi alırken kendi çantanızı getirerek hem doğaya hem de kendinize katkıda bulunun! Yanınızda çantanız yoksa, işletmeden uygun fiyata kraft kâğıt ambalaj temin edebilirsiniz.
''';
  */

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final business = findBusinessById(p.businessId);
    final cart = ref.watch(cartProvider);

    final existingQty = cart.firstWhere(
          (e) => e.id == p.packageName,
      orElse: () => CartItem(id: '', name: '', shopId: '', shopName: '', image: '', price: 0, quantity: 0),
    ).quantity;
    final remaining = (maxQty - existingQty).clamp(0, maxQty); // kalan stok

    if (business == null) {
      return const Scaffold(
        body: Center(child: Text('İşletme bilgisi bulunamadı.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _header(p, business),
              _packageCard(p, business),
              _infoCard('Bu pakette seni ne bekliyor?',
                  'Lezzetli sandviçler, tek porsiyonluk tatlılar, atıştırmalık kokteyller.'),
              const KnowMoreFull(),
              _deliveryCard(business),
              _ratingCard(business),
              _mapCard(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

// ——— Floating Sepet Butonu ———
          Consumer(
            builder: (context, ref, _) {
              final cart = ref.watch(cartProvider);
              if (cart.isEmpty) return const SizedBox.shrink();

              return Positioned(
                right: 16,
                bottom: MediaQuery.of(context).padding.bottom + 90,
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/cart'),
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  label: const Text(
                    'Sepete Git',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDarkGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 8,
                  ),
                ),
              );
            },
          ),

          // 🔹 Bottom Bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ProductBottomBar(
              qty: qty,
              price: p.newPrice,
              onAdd: () {
                if (qty < remaining) setState(() => qty++);
              },
              onRemove: () => setState(() => qty = math.max(1, qty - 1)),
              isDisabled: remaining == 0, // sepetteki ile toplam limit dolduysa buton kilit
              onSubmit: () async {
                // toplam istenen = sepettekiler + ekrandaki adet
                if (qty > remaining) return false; // güvenlik: fazla istiyorsa ekleme

                final ctrl = ref.read(cartProvider.notifier);
                final biz = findBusinessById(p.businessId);
                if (biz == null) return false;

                final currentShop = ctrl.currentShopId();
                final sameShop = (currentShop == null) || (currentShop == biz.id);

                if (sameShop) {
                  ctrl.addProduct(p, biz, qty: qty);
                  return true; // gerçekten eklendi
                } else {
                  final proceed = await showCartConflictModal(context);
                  if (proceed == true) {
                    ctrl.replaceWith(p, biz, qty: qty);
                    // burada mesajı bu ekranda göstermek istersen true döndürelim,
                    // toast zaten buton içinde ok==true olduğunda çıkacak:
                    return true;
                  }
                  return false; // vazgeçildi -> toast yok
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 Header
  Widget _header(ProductModel p, BusinessModel business) => SliverAppBar(
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
          isFav: isFav,
          onToggle: () => setState(() => isFav = !isFav),
          context: context,
        ),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(p.bannerImage, fit: BoxFit.cover),
          Positioned(
            top: 120,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: AppColors.primaryDarkGreen, width: 1.2),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                p.stockLabel,
                style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: CircleAvatar(
              radius: 37,
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
        ],
      ),
    ),
  );

  // 🔸 Diğer Yardımcı Widget’lar
  Widget _card({required Widget child}) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
        ),
      ],
    ),
    child: child,
  );

  Widget _packageCard(ProductModel p, BusinessModel business) =>
      SliverToBoxAdapter(
        child: _card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.packageName,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(p.pickupTimeText,
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                    ]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${p.oldPrice.toStringAsFixed(0)} TL',
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 13)),
                  Text('${p.newPrice.toStringAsFixed(0)} TL',
                      style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.primaryDarkGreen,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _infoCard(String title, String content) => SliverToBoxAdapter(
    child: _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(content,
              style: TextStyle(color: Colors.grey.shade800, height: 1.35)),
        ],
      ),
    ),
  );

  Widget _deliveryCard(BusinessModel business) => SliverToBoxAdapter(
    child: _card(
      child: InkWell(
        onTap: () => context.go('/businessShop-detail', extra: business),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.storefront_outlined,
                color: AppColors.primaryDarkGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(business.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDarkGreen,
                          decoration: TextDecoration.underline)),
                  const SizedBox(height: 4),
                  Text(business.address,
                      style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _ratingCard(BusinessModel business) => SliverToBoxAdapter(
    child: _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('İşletme Değerlendirme',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Icon(Icons.star,
                  size: 16, color: AppColors.primaryDarkGreen),
              const SizedBox(width: 4),
              Text('${business.rating.toStringAsFixed(1)} (70+)'),
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
  );

  Widget _mapCard() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 9),
      child: ClipRRect(
        child: Image.asset(
          'assets/images/sample_map.png',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );

  Widget _ratingRow(String label, double value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 140, child: Text(label)),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 5,
            backgroundColor: Colors.grey[200],
            color: AppColors.primaryDarkGreen,
            minHeight: 6,
          ),
        ),
        const SizedBox(width: 8),
        Text(value.toStringAsFixed(1)),
      ],
    ),
  );

  Widget _roundIcon({required IconData icon, VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
    child: GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    ),
  );
}