import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../features/stores/data/model/store_summary.dart';
import 'navigation_link.dart';

class StoreDeliveryInfoCard extends StatelessWidget {
  final StoreSummary store;
  final VoidCallback? onStoreTap;

  const StoreDeliveryInfoCard({
    super.key,
    required this.store,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          onTap: onStoreTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// LOGO
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryLightGreen,
                backgroundImage: store.imageUrl.isNotEmpty
                    ? NetworkImage(store.imageUrl)
                    : null,
                child: store.imageUrl.isEmpty
                    ? const Icon(Icons.store, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),

              /// INFO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// NAME + RATING
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        /// ⭐ RATING (varsa)
                        if (store.overallRating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDarkGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  store.overallRating!
                                      .toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// DISTANCE
                    if (store.distanceKm != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${store.distanceKm!.toStringAsFixed(1)} km",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 6),

                    /// NAVIGATION
                    NavigationLink(
                      address: store.address,
                      latitude: store.latitude,
                      longitude: store.longitude,
                      label: store.name,
                      textStyle: const TextStyle(
                        color: AppColors.primaryDarkGreen,
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right,
                  color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
