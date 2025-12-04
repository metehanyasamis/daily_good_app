// lib/features/stores/presentation/widgets/store_card.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../product/data/models/store_summary.dart'; // ÖNEMLİ: StoreSummary import

class StoreCard extends StatelessWidget {
  final StoreSummary store;
  const StoreCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push("/stores/${store.id}"),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withOpacity(0.05),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Image.network(
                store.bannerImageUrl ?? "",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    store.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 6),

                  if (store.distanceKm != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14),
                        Text("${store.distanceKm!.toStringAsFixed(2)} km"),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
