import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/custom_toggle_button.dart';

import '../../../location/domain/address_notifier.dart';
import '../../../product/data/repository/product_repository.dart';
import '../../../stores/data/model/store_summary.dart';
import '../../domain/providers/explore_store_provider.dart';
import '../widgets/half_store_sheet.dart';
import '../widgets/mini_store_card.dart';
import '../widgets/store_marker_layer.dart';

class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  StoreSummary? _selectedStore;

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(addressProvider);
    final storesAsync = ref.watch(exploreStoreProvider);

    if (!address.isSelected) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: CustomHomeAppBar(
        address: address.title,
        onLocationTap: () => context.push('/location-picker'),
        onNotificationsTap: () {},
      ),
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Hata: $err")),
        data: (stores) {


          // 👇👇👇 TAM BURAYA
          debugPrint('🟦 MAP STORES COUNT: ${stores.length}');
          for (final s in stores) {
            debugPrint(
              '📍 STORE: ${s.name} lat=${s.latitude} lng=${s.longitude}',
            );
          }
          // 👆👆👆

          return Stack(
            children: [
              /// 🗺️ MAP
              StoreMarkerLayer(
                address: address,
                stores: stores,
                onMapTap: () => setState(() => _selectedStore = null),
                onStoreSelected: (store) {
                  setState(() => _selectedStore = store);
                },
              ),

              /// 🟢 MINI STORE CARD
              if (_selectedStore != null)
                Positioned(
                  left: 16,
                  right: MediaQuery.of(context).size.width * 0.27,
                  bottom: (MediaQuery.of(context).padding.bottom > 0
                      ? MediaQuery.of(context).padding.bottom
                      : 20) +
                      80,
                  child: MiniStoreCard(
                    store: _selectedStore!,
                    onTap: () => _openHalfStoreSheet(_selectedStore!),
                  ),
                ),



              /// 🔘 MAP → LIST
              CustomToggleButton(
                label: "Liste",
                icon: Icons.list,
                onPressed: () => context.go('/explore'),
              ),
            ],
          );
        },
      ),
    );
  }

// ExploreMapScreen içindeki ilgili kısım:
  void _openHalfStoreSheet(StoreSummary store) {
    final productRepo = ref.read(productRepositoryProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HalfStoreSheet(
        store: store,
        // 🔥 DOĞRU ÇAĞRI: fetchProductsFlat tüm grupları birleştirip Liste döner
        productsFuture: productRepo.fetchProductsList(
          storeId: store.id,
          perPage: 20,
        ),
        onStoreTap: () => context.push('/store-detail/${store.id}'),
      ),
    );
  }


}
