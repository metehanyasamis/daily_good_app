import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/fav_button.dart';
import '../../../../core/widgets/know_more_full.dart';
import '../../../../core/widgets/floating_cart_button.dart';
import '../../../../core/widgets/product_bottom_bar.dart';

import '../../../../core/widgets/store_delivery_info_card.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../../cart/presentation/widgets/cart_warning_modal.dart';

import '../../../stores/data/model/store_detail_model.dart';
import '../../../stores/domain/providers/store_detail_provider.dart';
import '../../../stores/presentation/widgets/store_map_card.dart';
import '../../domain/products_notifier.dart';
import '../../data/models/product_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState
    extends ConsumerState<ProductDetailScreen> {
  int qty = 1;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsNotifier = ref.read(productsProvider.notifier);
      final productState = ref.read(productsProvider);

      if (productState.selectedProduct == null ||
          productState.selectedProduct!.id != widget.productId) {
        productsNotifier.fetchDetail(widget.productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productsProvider);
    final product = productState.selectedProduct;

    if (product == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔥 TEK DOĞRU KAYNAK
    final storeId = product.store.id;

    // 🔥 FAMILY DOĞRU KULLANIM
    final storeState = ref.watch(storeDetailProvider(storeId));

    if (storeState.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (storeState.error != null) {
      return Scaffold(
        body: Center(child: Text("Hata: ${storeState.error}")),
      );
    }

    final store = storeState.detail;
    if (store == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _header(product),
              _packageCard(product),
              _infoCard(
                "Bu pakette seni ne bekliyor?",
                "İçerik bilgisi backend’den gelecek.",
              ),
              const KnowMoreFull(),
              _storeDeliveryCard(product),
              _ratingCard(product),


              SliverToBoxAdapter(
                child: StoreMapCard(
                  storeId: store.id,
                  latitude: store.latitude,
                  longitude: store.longitude,
                  address: store.address,
                ),
              ),


              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          const FloatingCartButton(),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _bottomBar(product),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HEADER (Banner + Fav + Stock)
  // ---------------------------------------------------------------------------

  SliverAppBar _header(ProductModel p) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 240,
      backgroundColor: Colors.white,
      leading: _roundIcon(
        icon: Icons.arrow_back_ios_new_rounded,
        onTap: () => context.pop(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: FavButton(id: p.id),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              p.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: Colors.grey.shade200),
            ),

            // STOCK BADGE (placeholder)
            Positioned(
              top: 140,
              left: 0,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  "Son paketler",
                  style: TextStyle(
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PACKAGE + PRICE
  // ---------------------------------------------------------------------------

  SliverToBoxAdapter _packageCard(ProductModel p) {
    return SliverToBoxAdapter(
      child: _card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${p.deliveryTimeLabel}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${p.listPrice.toStringAsFixed(0)} ₺",
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "${p.salePrice.toStringAsFixed(0)} ₺",
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.primaryDarkGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INFO CARD
  // ---------------------------------------------------------------------------

  SliverToBoxAdapter _infoCard(String title, String content) {
    return SliverToBoxAdapter(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // RATINGCARD
  // ---------------------------------------------------------------------------

  SliverToBoxAdapter _ratingCard(ProductModel p) {
    final s = p.store;

    if (s.averageRatings == null || s.overallRating == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final r = s.averageRatings!;

    return SliverToBoxAdapter(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "İşletme Değerlendirme",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Icon(Icons.star,
                    size: 16, color: AppColors.primaryDarkGreen),
                const SizedBox(width: 4),
                Text(
                  "${s.overallRating!.toStringAsFixed(1)}"
                      " (${s.totalReviews ?? 0})",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _ratingRow("Servis", r.service),
            _ratingRow("Ürün Miktarı", r.productQuantity),
            _ratingRow("Lezzet", r.productTaste),
            _ratingRow("Çeşitlilik", r.productVariety),
          ],
        ),
      ),
    );
  }


  Widget _ratingRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: (value / 5).clamp(0, 1),
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primaryDarkGreen,
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(1)),
        ],
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // STORE DELIVERY
  // ---------------------------------------------------------------------------

  SliverToBoxAdapter _storeDeliveryCard(
      ProductModel p, {
        String? storeWorkingHoursLabel,
      }) {
    final s = p.store;

    debugPrint(
      "🏪 STORE DEBUG → "
          "name=${s.name} | "
          "rating=${s.overallRating} | "
          "reviews=${s.totalReviews}",
    );

    return SliverToBoxAdapter(
      child: StoreDeliveryInfoCard(
        store: s,
        onStoreTap: () => context.push('/store-detail/${s.id}'),
      ),
    );
  }

// ---------------------------------------------------------------------------
// MAP CARD (STABLE - DEBUG READY)
// ---------------------------------------------------------------------------
/*
  SliverToBoxAdapter mapCard(StoreDetailModel store) {
    debugPrint(
      "🗺️ MAP CARD BUILD → "
          "id=${store.id} | lat=${store.latitude} | lng=${store.longitude}",
    );

    if (store.latitude == 0 || store.longitude == 0) {
      debugPrint("⚠️ MAP SKIPPED → invalid coordinates");
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Konum",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),

            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 220,
                child: MapWidget(
                  key: ValueKey(
                    "store-map-${store.id}-${store.latitude}-${store.longitude}",
                  ),

                  onMapCreated: (MapboxMap mapboxMap) async {
                    debugPrint("✅ MAP CREATED → store=${store.id}");

                    try {
                      // 1️⃣ STYLE
                      debugPrint("🎨 Loading style...");
                      await mapboxMap.loadStyleURI(
                        MapboxStyles.MAPBOX_STREETS,
                      );

                      // küçük bekleme (native surface)
                      await Future.delayed(const Duration(milliseconds: 300));

                      // 2️⃣ CAMERA
                      debugPrint("🎥 Setting camera...");
                      await mapboxMap.setCamera(
                        CameraOptions(
                          center: Point(
                            coordinates: Position(
                              store.longitude,
                              store.latitude,
                            ),
                          ),
                          zoom: 15,
                        ),
                      );

                      // 3️⃣ ANNOTATION MANAGER
                      debugPrint("📍 Creating annotation manager...");
                      final pointManager = await mapboxMap.annotations
                          .createPointAnnotationManager();

                      await pointManager.deleteAll();

                      // 4️⃣ MARKER IMAGE
                      debugPrint("🖼️ Loading marker asset...");
                      final data = await rootBundle
                          .load('assets/icons/store_marker.png');
                      final bytes = data.buffer.asUint8List();

                      // 5️⃣ MARKER
                      debugPrint("📌 Creating marker...");
                      await pointManager.create(
                        PointAnnotationOptions(
                          geometry: Point(
                            coordinates: Position(
                              store.longitude,
                              store.latitude,
                            ),
                          ),
                          image: bytes,
                          iconSize: 0.22,
                          iconAnchor: IconAnchor.BOTTOM,
                        ),
                      );

                      debugPrint(
                        "✅ MARKER SET → ${store.latitude}, ${store.longitude}",
                      );
                    } catch (e, s) {
                      debugPrint("❌ MAP ERROR → $e");
                      debugPrint("📛 STACK → $s");
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: AppColors.primaryDarkGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    store.address,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
*/


  // ---------------------------------------------------------------------------
  // BOTTOM BAR
  // ---------------------------------------------------------------------------

  Widget _bottomBar(ProductModel p) {
    final cartCtrl = ref.read(cartProvider.notifier);

    return ProductBottomBar(
      qty: qty,
      price: p.salePrice,
      onAdd: () => setState(() => qty++),
      onRemove: () =>
          setState(() => qty = math.max(1, qty - 1)),
      onSubmit: () async {
        final sameStore = cartCtrl.isSameStore(p.store.id);

        if (sameStore) {
          return await cartCtrl.addProduct(p, qty);
        }

        final proceed = await showCartConflictModal(context);
        if (proceed == true) {
          return await cartCtrl.replaceWith(p, qty);
        }
        return false;
      },
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _card({required Widget child}) {
    return Container(
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
  }

  Widget _roundIcon(
      {required IconData icon, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
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
              ),
            ],
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
