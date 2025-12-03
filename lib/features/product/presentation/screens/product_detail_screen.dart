// lib/features/product/presentation/screens/product_detail_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/floating_cart_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../../core/widgets/product_bottom_bar.dart';
import '../../../../core/widgets/fav_button.dart';
// ❌ Mock bağımlılıkları kaldırıldı
// import '../../../businessShop/data/mock/mock_businessShop_model.dart';
// import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../cart/domain/models/cart_item.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';
import '../../data/models/product_model.dart';
// Yeni provider'ı import et
import '../../domain/providers/product_list_provider.dart';


// 💡 Not: Artık bu ekran route üzerinden sadece `productId` alacak.
// ProductModel'i burada FutureProvider ile çekmeliyiz.

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 productDetailProvider'ı kullanarak veriyi çekiyoruz
    final detailAsync = ref.watch(productDetailProvider(productId));

    return detailAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text('Hata: $err')),
      ),
      data: (product) {
        // Veri geldi, artık product ve store bilgileri elimizde.
        return _ProductDetailContent(product: product);
      },
    );
  }
}

// 💡 Veri geldikten sonra gösterilecek ana widget
class _ProductDetailContent extends ConsumerStatefulWidget {
  final ProductModel product;
  const _ProductDetailContent({required this.product});

  @override
  ConsumerState<_ProductDetailContent> createState() =>
      __ProductDetailContentState();
}

class __ProductDetailContentState extends ConsumerState<_ProductDetailContent> {
  int qty = 1;
  bool expanded = false;

  // 🔹 stok limiti (API'den gelen `stock` kullanılır)
  int get maxQty => widget.product.stock;


  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final store = p.store; // 🔥 Artık ProductStoreModel kullanıyoruz
    final cart = ref.watch(cartProvider);

    // Sepet kontrolü
    final existingQty = cart.firstWhere(
          (e) => e.id == p.name, // Ürün adı sepet öğesinin adı olarak kullanılıyordu
      orElse: () => CartItem(id: '', name: '', shopId: '', shopName: '', image: '', price: 0, quantity: 0),
    ).quantity;
    final remaining = (maxQty - existingQty).clamp(0, maxQty); // kalan stok

    // 💡 BusinessModel'i kullanmak yerine, ProductStoreModel'in alanlarını kullanıyoruz.
    // Eğer tüm BusinessShop ekranları için BusinessModel kullanıyorsak, ProductStoreModel'den BusinessModel'e çeviren bir factory metot yazmak daha tutarlı olabilir. Şimdilik ProductStoreModel'i doğrudan kullanacağız.

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _header(p, store), // 🔥 BusinessModel yerine ProductStoreModel
              _packageCard(p),
              _infoCard('Bu pakette seni ne bekliyor?',
                  'Lezzetli sandviçler, tek porsiyonluk tatlılar, atıştırmalık kokteyller.'), // Burası için API'de açıklama alanı yok, mock metin kaldı
              const KnowMoreFull(),
              _deliveryCard(store), // 🔥 BusinessModel yerine ProductStoreModel
              _ratingCard(store), // 🔥 BusinessModel yerine ProductStoreModel
              _mapCard(),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          const FloatingCartButton(),

          // 🔹 Bottom Bar
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ProductBottomBar(
              qty: qty,
              price: p.salePrice,
              onAdd: () {
                if (qty < remaining) setState(() => qty++);
              },
              onRemove: () => setState(() => qty = math.max(1, qty - 1)),
              isDisabled: remaining == 0,
              onSubmit: () async {
                if (qty > remaining) return false;

                final ctrl = ref.read(cartProvider.notifier);

                // 🔥 Sepete ekleme için BusinessModel yerine ProductStoreModel kullanıldı
                final currentShop = ctrl.currentShopId();
                final sameShop = (currentShop == null) || (currentShop == store.id);

                // 💡 Sepet öğesi oluştururken artık ProductStoreModel'den BusinessModel'e dönüşüm gerekli
                // veya CartItem'ı ProductStoreModel alacak şekilde revize etmeliyiz.
                // Şimdilik CartItem'a ProductModel ve ProductStoreModel bilgisi gönderelim (En hızlı yol)

                // NOT: CartItem'a shopName ve shopId ProductStoreModel'den geliyor.
                // BusinessModel gereksizdi, CartProvider'daki `addProduct` metodunun imzasına bakılmalı.

                // Varsayım: CartProvider.addProduct metodu sadece ProductModel ve ProductStoreModel alanlarını kullanıyor.
                final cartItemProduct = p; // ProductModel zaten var
                final shopId = store.id;
                final shopName = store.name;
                final shopImage = store.bannerImageUrl;


                if (sameShop) {
                  // Sepet item'ını CartItem.fromProductModel ile oluşturmalısınız.
                  // Şimdilik doğrudan P'yi geçirip, CartProvider'ın halledeceğini varsayalım
                  // (bu, CartProvider'ın da refactor edilmesini gerektirir).
                  ctrl.addProductFromApi(cartItemProduct, shopId, shopName, shopImage, qty: qty);
                  return true;
                } else {
                  final proceed = await showCartConflictModal(context);
                  if (proceed == true) {
                    ctrl.replaceWithApi(cartItemProduct, shopId, shopName, shopImage, qty: qty);
                    return true;
                  }
                  return false;
                }
              },
            ),
          ),
        ],
      ),
    );

  }

  // 🔸 Header
  // 🔥 BusinessModel yerine ProductStoreModel kullanıldı
  Widget _header(ProductModel p, ProductStoreModel store) => SliverAppBar(
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
          item: widget.product,
        ),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          // 🔥 Image.network kullan
          Image.network(
            p.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey.shade200,
              child: const Center(child: Icon(Icons.broken_image)),
            ),
          ),
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
                p.stockLabel, // 🔥 Getter'dan geldi
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
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryDarkGreen,
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white,
                child: ClipOval(
                  // 🔥 Logo URL kullan
                  child: Image.network(
                    store.brand.logoUrl ?? 'assets/logos/default_brand.png',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/logos/default_brand.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  // 🔸 Diğer Yardımcı Widget’lar (Burada sadece parametreleri güncelledik)
  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) =>
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

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

  Widget _packageCard(ProductModel p) =>
      SliverToBoxAdapter(
        child: _card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, // 🔥 API "name"
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(p.pickupTimeText, // 🔥 Getter
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                    ]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${p.listPrice.toStringAsFixed(0)} TL', // 🔥 API "list_price"
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 13)),
                  Text('${p.salePrice.toStringAsFixed(0)} TL', // 🔥 API "sale_price"
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

  // 🔥 BusinessModel yerine ProductStoreModel kullanıldı
  Widget _deliveryCard(ProductStoreModel store) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Başlık
            const Text(
              "Teslim alma bilgileri",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.primaryDarkGreen.withOpacity(0.3),
            ),
            const SizedBox(height: 12),

            // 🏪 İşletme Bilgisi
            InkWell(
              // 💡 BusinessDetailScreen'e yönlendirirken store.id kullanıldı
              onTap: () => context.push('/businessShop-detail', extra: store.id),
              borderRadius: BorderRadius.circular(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    color: AppColors.primaryDarkGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 10),

                  // 🔹 Metinler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İşletme Adı
                        Text(
                          store.name, // 🔥 Store modelinden geldi
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Adres Bilgisi
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: AppColors.primaryDarkGreen,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                store.address ?? 'Adres bilgisi yok.', // 🔥 Product Detayında var
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  // 🔥 BusinessModel yerine ProductStoreModel kullanıldı
  Widget _ratingCard(ProductStoreModel store) => SliverToBoxAdapter(
    child: _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Müşteri Değerlendirmeleri',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('Tümü (${0})', style: const TextStyle(color: AppColors.primaryDarkGreen)),
            ],
          ),
          // 💡 Burada RatingList widget'ı yer alacaktır.
          // Store ID: store.id
        ],
      ),
    ),
  );

  // 💡 Harita widget'ının businessShop bağımlılığı olacağı varsayılır.
  Widget _mapCard() => const SliverToBoxAdapter(
    child: SizedBox(
      height: 200,
      child: Center(child: Text('Harita Widget (Google Maps/Yandex/etc.)')),
    ),
  );
}