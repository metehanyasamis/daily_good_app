import 'package:flutter/material.dart';

import '../../../stores/data/model/store_summary.dart';

class MiniStoreCard extends StatelessWidget {
  final StoreSummary store;
  final VoidCallback onTap;

  const MiniStoreCard({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(store.imageUrl),
                radius: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store.overallRating != null)
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            store.overallRating!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

