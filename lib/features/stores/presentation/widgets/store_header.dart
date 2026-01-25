// lib/features/stores/presentation/widgets/store_header.dart

import 'package:flutter/material.dart';

import '../../data/model/store_detail_model.dart';


class StoreHeader extends StatelessWidget {
  final StoreDetailModel store;
  const StoreHeader({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner
        Image.network(
          store.bannerImageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
        ),

        const SizedBox(height: 12),

        Text(
          store.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          store.address,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 6),

        if (store.distanceKm != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              Text("${store.distanceKm!.toStringAsFixed(2)} km"),
            ],
          ),

        const SizedBox(height: 14),
      ],
    );
  }
}
