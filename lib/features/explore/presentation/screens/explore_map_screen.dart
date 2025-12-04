import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../stores/data/model/store_detail_model.dart';

// ❗ Geçici: Backend hazır olana kadar boş liste döner
final exploreBusinessListProvider =
FutureProvider<List<StoreDetailModel>>((ref) async {
  return [];
});

class ExploreMapScreen extends ConsumerStatefulWidget {
  const ExploreMapScreen({super.key});

  @override
  ConsumerState<ExploreMapScreen> createState() => _ExploreMapScreenState();
}

class _ExploreMapScreenState extends ConsumerState<ExploreMapScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(exploreBusinessListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: CustomHomeAppBar(
        address: 'Nail Bey Sok.',
        onLocationTap: () {},
        onNotificationsTap: () {},
      ),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Hata: $err")),
        data: (businesses) {
          // Backend gelene kadar boş → sadece bilgi mesajı gösterelim
          if (businesses.isEmpty) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(41.0082, 28.9784), // İstanbul
                      zoom: 12,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: (c) => _mapController = c,
                    markers: {},
                  ),
                ),

                Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Text(
                      "Explore backend henüz hazır değil.\nHarita sadece görüntüleniyor.",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                // Toggle Button (harita → liste)
                CustomToggleButton(
                    label: "Liste",
                    icon: Icons.list,
                    onPressed: () => context.push('/explore')),
              ],
            );
          }

          // Backend gelince burası çalışacak
          return Container();
        },
      ),
    );
  }
}
