import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../businessShop/data/mock/mock_businessShop_model.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../product/data/models/product_model.dart';

class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  final List<BusinessModel> _sampleBusinessShop = mockBusinessList;
  String? _selectedShopId;
  GoogleMapController? _mapController;

  BusinessModel? get _selectedShop {
    if (_selectedShopId == null) return null;
    try {
      return _sampleBusinessShop.firstWhere((s) => s.id == _selectedShopId);
    } catch (_) {
      return null;
    }
  }

  /// 📍 Marker’ları işletmelerden üret
  Set<Marker> _buildMarkers() {
    return _sampleBusinessShop.map((shop) {
      return Marker(
        markerId: MarkerId(shop.id),
        position: LatLng(shop.latitude, shop.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
        onTap: () => _onPinTap(shop.id),
      );
    }).toSet();
  }

  void _onPinTap(String shopId) {
    setState(() {
      if (_selectedShopId == shopId) {
        _onCardTap();
      } else {
        _selectedShopId = shopId;
      }
    });
  }

  void _onCardTap() {
    final business = _selectedShop;
    if (business == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: controller,
            child: _HalfBusinessDetailCard(
              business: business,
              onBusinessTap: () =>
                  context.push('/businessShop-detail', extra: business),
              onProductTap: (product) =>
                  context.push('/product-detail', extra: product),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,

      // ✅ Üstte Custom App Bar (şimdilik sabit adres, sonra HomeState’e bağlarız)
      appBar: CustomHomeAppBar(
        address: 'Nail Bey Sok.',
        onLocationTap: () async {
          // 📍 İleride buradan location_picker_screen'e gideceğiz
          // final result = await context.push('/location-picker');
        },
        onNotificationsTap: () {
          // 🔔 Bildirim ekranı
        },
      ),

      body: Stack(
        children: [
          // 🗺️ GERÇEK Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(41.0082, 28.9784), // İstanbul genel
                zoom: 12,
              ),
              markers: _buildMarkers(),
              onMapCreated: (c) => _mapController = c,
              onTap: (_) {
                // Haritada boş alana tıklayınca mini kartı kapat
                setState(() => _selectedShopId = null);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),

          // 🪧 Alt mini kart (tasarımına DOKUNMADIM)
          if (_selectedShop != null)
            Positioned(
              left: 16,
              right: MediaQuery.of(context).size.width * 0.27,
              bottom: (MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom
                  : 20) +
                  80, // toggle alt seviyesi
              child: GestureDetector(
                onTap: _onCardTap,
                child: _MiniBusinessCard(business: _selectedShop!),
              ),
            ),

          // 🟢 Toggle Buton (tasarım aynı)
          CustomToggleButton(
            label: "Liste",
            icon: Icons.list,
            onPressed: () => context.push('/explore'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Mini Kart (SENİN ORİJİNALİN) ----------------
class _MiniBusinessCard extends StatelessWidget {
  final BusinessModel business;
  const _MiniBusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(business.businessShopLogoImage),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star,
                          color: Colors.amber, size: 15),
                      Text(
                        business.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Bugün teslim al: ${business.workingHours}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 22, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

// ---------------- Yarım Bilgi Kartı (SENİN ORİJİNALİN) ----------------
class _HalfBusinessDetailCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onBusinessTap;
  final void Function(ProductModel product) onProductTap;

  const _HalfBusinessDetailCard({
    required this.business,
    required this.onBusinessTap,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBusinessTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundImage: AssetImage(business.businessShopLogoImage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              business.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 3),
                              Text(
                                business.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${business.distance.toStringAsFixed(1)} km • ${business.address}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      Text(
                        "Çalışma Saatleri: ${business.workingHours}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Seni bekleyen lezzetler",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),

          ...business.products.map((product) {
            return GestureDetector(
              onTap: () => onProductTap(product),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        product.bannerImage,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.packageName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.pickupTimeText,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${product.oldPrice.toStringAsFixed(0)} ₺",
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              "${product.newPrice.toStringAsFixed(0)} ₺",
                              style: const TextStyle(
                                color: AppColors.primaryDarkGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
