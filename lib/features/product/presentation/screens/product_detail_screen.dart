import 'dart:math' as math;
import 'package:daily_good/features/stores/data/model/store_detail_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/platform/platform_widgets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../../core/widgets/floating_cart_button.dart';
import '../../../../core/widgets/product_bottom_bar.dart';
import '../../../../core/widgets/store_delivery_info_card.dart';

import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';
import '../../../settings/domain/providers/legal_settings_provider.dart';
import '../../../stores/data/model/store_summary.dart';
import '../../../stores/domain/providers/store_detail_provider.dart';
import '../../../stores/presentation/widgets/store_map_card.dart';
import '../../domain/products_notifier.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int qty = 1;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(productsProvider.notifier);
      notifier.clearDetail();
      notifier.fetchDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productsProvider);
    final product = productState.selectedProduct;

    final settingsAsync = ref.watch(legalSettingsProvider);

    if (product == null || product.id != widget.productId) {
      return Scaffold(
        body: Center(
          child: PlatformWidgets.loader(), // 🚀 Otomatik olarak iOS'ta farklı, Android'de farklı görünür
        ),
      );
    }

    final storeId = product.store.id;
    if (storeId.isEmpty) {
      return _ErrorScaffold(message: "Mağaza bilgisi bulunamadı.", title: product.name);
    }

    final storeState = ref.watch(storeDetailProvider(storeId));

    // Durum Kontrolleri
    if (storeState.loading) {
      return Scaffold(
        body: Center(
          child: PlatformWidgets.loader(),
        ),
      );
    }
    if (storeState.error != null) return _ErrorScaffold(message: "Hata: ${storeState.error}");

    final store = storeState.detail;
    if (store == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                _ProductHeader(product: product),
                _ProductInfoSection(product: product),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
        
                // 🎯 ÇÖZÜM: Veri varsa gönderiyoruz, yoksa null (default metin görünecek)
                KnowMoreFull(
                  customInfo: settingsAsync.value?.importantInfo,
                ),
        
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                _StoreSection(product: product, freshStore: store.toStoreSummary()),              //_RatingSection(product: product),
                SliverToBoxAdapter(
                  child: store.latitude != 0.0 && store.longitude != 0.0
                      ? StoreMapCard(
                    storeId: store.id,
                    latitude: store.latitude,
                    longitude: store.longitude,
                    address: store.address,
                  )
                      : const SizedBox.shrink(), // Koordinat yoksa haritayı hiç çizme, patlamasın
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
            const FloatingCartButton(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(product),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ProductModel p) {
    return ProductBottomBar(
      qty: qty,
      price: p.salePrice,
      onAdd: () => setState(() => qty++),
      onRemove: () => setState(() => qty = math.max(1, qty - 1)),
      onSubmit: () async {
        final cartCtrl = ref.read(cartProvider.notifier);
        if (cartCtrl.isSameStore(p.store.id)) {
          return await cartCtrl.addProduct(p, qty);
        }
        final proceed = await showCartConflictModal(context);
        if (proceed == true) return await cartCtrl.replaceWith(p, qty);
        return false;
      },
    );
  }
}

// --- Yardımcı Küçük Widget Bileşenleri ---

class _ProductHeader extends StatelessWidget {
  final ProductModel product;
  const _ProductHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // İndirim hesaplama
    final discount = product.listPrice > 0
        ? ((product.listPrice - product.salePrice) / product.listPrice * 100).round()
        : 0;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 230 + statusBarHeight,
      backgroundColor: Colors.white,
      leading: _CircularIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => context.pop(),
      ),
      actions: [
        // Sadece Favori Butonu kalıyor, indirim aşağıya Stack'e taşındı
        FavButton(id: product.id, isStore: false),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ürün Görseli
            Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey.shade200),
            ),

            // 🟢 SOL DUVAR: STOK ADET ETİKETİ
            Positioned(
              top: kToolbarHeight + 10,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))
                  ],
                ),
                child: Text(
                  "${product.stock} adet",
                  style: const TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            // 🔴 SAĞ DUVAR: İNDİRİM ORANI ETİKETİ
            if (discount > 0)
              Positioned(
                top: kToolbarHeight + 10,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDarkGreen, // İndirim için kurumsal yeşil
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(-2, 2))
                    ],
                  ),
                  child: Text(
                    "-%$discount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _ProductInfoSection extends StatelessWidget {
  final ProductModel product;
  const _ProductInfoSection({required this.product});

  @override
  Widget build(BuildContext context) {
    // Tarih formatlama yardımcı fonksiyonu
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr == "null" || dateStr.isEmpty) return "-";
      try {
        final date = DateTime.parse(dateStr);
        return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
      } catch (_) { return dateStr; }
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                      product.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                  ),
                ),
                _PriceWidget(listPrice: product.listPrice, salePrice: product.salePrice),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Bu pakette seni ne bekliyor?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              product.description ?? "İçerik bilgisi bulunmamaktadır.",
              style: TextStyle(color: Colors.grey.shade800, height: 1.4, fontSize: 15),
            ),
            const SizedBox(height: 16),

            // --- YENİ REFACTOR EDİLEN BÖLÜM: TARİH VE SAAT ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  // Tarih Bilgisi
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${formatDate(product.startDate)} - ${formatDate(product.endDate)} tarihlerinde",
                          style: const TextStyle(
                              fontSize: 14,
                              //fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                  // Saat Bilgisi
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded, size: 20, color: AppColors.primaryDarkGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${product.startHour.substring(0, 5)} - ${product.endHour.substring(0, 5)} saatleri arasında",
                          style: const TextStyle(
                              fontSize: 14,
                              //fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // -----------------------------------------------

          ],
        ),
      ),
    );
  }
}

class _PriceWidget extends StatelessWidget {
  final double listPrice;
  final double salePrice;
  const _PriceWidget({required this.listPrice, required this.salePrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("${listPrice.toStringAsFixed(0)} ₺", style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
        Text("${salePrice.toStringAsFixed(0)} ₺", style: const TextStyle(fontSize: 22, color: AppColors.primaryDarkGreen, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _StoreSection extends StatelessWidget {
  final ProductModel product;
  final StoreSummary? freshStore; // 👈 Taze veri
  const _StoreSection({required this.product, this.freshStore});

  @override
  Widget build(BuildContext context) {
    // Eğer freshStore (detaylı API'den gelen) varsa onu kullan,
    // yoksa ürünün içindekini (puanı 0.0 olanı) kullan.
    final storeToShow = freshStore ?? product.store;

    return SliverToBoxAdapter(
      child: StoreDeliveryInfoCard(
        store: storeToShow, // 👈 Artık puanı dolu olanı basacak
        onStoreTap: () => context.push('/store-detail/${storeToShow.id}'),
      ),
    );
  }
}


class _CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircularIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black, size: 18),
      ),
      onPressed: onTap,
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final String? title;
  const _ErrorScaffold({required this.message, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null ? AppBar(title: Text(title!)) : null,
      body: Center(child: Text(message)),
    );
  }
}