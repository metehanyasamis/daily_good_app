import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../../core/widgets/floating_cart_button.dart';
import '../../../../core/widgets/product_bottom_bar.dart';
import '../../../../core/widgets/store_delivery_info_card.dart';

import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';
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
      final state = ref.read(productsProvider);

      if (state.selectedProduct?.id != widget.productId) {
        notifier.fetchDetail(widget.productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productsProvider);
    final product = productState.selectedProduct;

    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final storeId = product.store.id;
    if (storeId.isEmpty) {
      return _ErrorScaffold(message: "Mağaza bilgisi bulunamadı.", title: product.name);
    }

    final storeState = ref.watch(storeDetailProvider(storeId));

    // Durum Kontrolleri
    if (storeState.loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (storeState.error != null) return _ErrorScaffold(message: "Hata: ${storeState.error}");

    final store = storeState.detail;
    if (store == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _ProductHeader(product: product),
              _ProductInfoSection(product: product),
              const KnowMoreFull(),
              _StoreSection(product: product),
              _RatingSection(product: product),
              SliverToBoxAdapter(
                child: store.latitude != 0.0 && store.longitude != 0.0
                    ? StoreMapCard(
                  storeId: store.id,
                  latitude: store.latitude!,
                  longitude: store.longitude!,
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
    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      backgroundColor: Colors.white,
      leading: _CircularIconButton(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => context.pop(),
      ),
      actions: [
        FavButton(id: product.id),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
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
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(product.deliveryTimeLabel, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                _PriceWidget(listPrice: product.listPrice, salePrice: product.salePrice),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Bu pakette seni ne bekliyor?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            const Text("İçerik bilgisi backend’den gelecek."),
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
  const _StoreSection({required this.product});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: StoreDeliveryInfoCard(
        store: product.store,
        onStoreTap: () => context.push('/store-detail/${product.store.id}'),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final ProductModel product;
  const _RatingSection({required this.product});

  @override
  Widget build(BuildContext context) {
    final s = product.store;
    if (s.averageRatings == null) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("İşletme Değerlendirme", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  const Icon(Icons.star, color: AppColors.primaryDarkGreen, size: 18),
                  Text(" ${s.overallRating?.toStringAsFixed(1) ?? '0.0'}"),
                ],
              ),
              const Divider(),
              _RatingBar(label: "Lezzet", value: s.averageRatings!.productTaste),
              _RatingBar(label: "Servis", value: s.averageRatings!.service),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Alt Bileşenler ---

class _RatingBar extends StatelessWidget {
  final String label;
  final double value;
  const _RatingBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        SizedBox(width: 100, child: LinearProgressIndicator(value: value / 5, color: AppColors.primaryDarkGreen, backgroundColor: Colors.grey.shade200)),
      ],
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