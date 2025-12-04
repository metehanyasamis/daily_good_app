import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../stores/data/model/store_detail_model.dart';

/// Backend hazır olana kadar boş liste döner
final exploreBusinessListProvider =
FutureProvider<List<StoreDetailModel>>((ref) async {
  return [];
});

class ExploreListScreen extends ConsumerWidget {
  const ExploreListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(exploreBusinessListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHomeAppBar(
        address: "Nail Bey Sok.",
        onLocationTap: () {},
        onNotificationsTap: () {},
      ),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Hata: $err")),
        data: (businesses) {
          // Backend henüz yok → Boş ekran + bilgilendirme banner
          if (businesses.isEmpty) {
            return Stack(
              children: [
                const Center(
                  child: Text(
                    "Explore backend henüz hazır değil.\nŞu an liste boş.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),

                // Map Toggle Button
                CustomToggleButton(
                  label: "Harita",
                  icon: Icons.map,
                  onPressed: () => context.go("/explore-map"),
                ),
              ],
            );
          }

          // Backend gelince burası aktif olacak
          return ListView.separated(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 120,
            ),
            itemCount: businesses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final store = businesses[index];

              return GestureDetector(
                onTap: () {
                  // Backend gelince StoreDetailScreen'e yönlendirme aktif olur
                  context.push("/stores-detail", extra: store);
                },
                child: _StoreListTile(store: store),
              );
            },
          );
        },
      ),
    );
  }
}

class _StoreListTile extends StatelessWidget {
  final StoreDetailModel store;
  const _StoreListTile({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Store logo (şimdilik placeholder)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              "assets/images/placeholder_logo.png",
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  store.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                /// Backend GELİNCE buraya:
                /// ⭐ rating
                /// ⭐ toplam yorum
                /// ⭐ çalışma saatleri
                /// ⭐ mesafe
                /// hepsi bağlanacak.
                const Text(
                  "Bilgiler yükleniyor…",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.black54)
        ],
      ),
    );
  }
}
