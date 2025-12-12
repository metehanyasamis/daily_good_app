import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_toggle_button.dart';
import '../../../../core/widgets/custom_home_app_bar.dart';
import '../../../location/domain/address_notifier.dart';
import 'explore_list_screen.dart';

class ExploreMapScreen extends ConsumerWidget {
  const ExploreMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(addressProvider);
    final businessesAsync = ref.watch(exploreBusinessListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      appBar: CustomHomeAppBar(
        address: address.title,
        onLocationTap: () {
          context.push('/location-picker');
        },
        onNotificationsTap: () {},
      ),
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Hata: $err")),
        data: (_) {
          return Stack(
            children: [
              /// 🗺️ MAPBOX
              MapWidget(
                cameraOptions: CameraOptions(
                  center: Point(
                    coordinates: Position(address.lng, address.lat),
                  ),
                  zoom: 14,
                ),
                styleUri: MapboxStyles.MAPBOX_STREETS,
                onTapListener: (context) {
                  final p = context.point.coordinates;
                  ref.read(addressProvider.notifier).setFromMap(
                    lat: p.lat.toDouble(),
                    lng: p.lng.toDouble(),
                  );
                },
              ),

              /// 🔘 Harita → Liste
              CustomToggleButton(
                label: "Liste",
                icon: Icons.list,
                onPressed: () => context.push('/explore'),
              ),
            ],
          );
        },
      ),
    );
  }
}
