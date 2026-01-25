import 'package:flutter/material.dart';

import '../../../../core/platform/platform_widgets.dart';
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
          height: 66, // 👈 eskiyle aynı
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LOGO
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: store.imageUrl.isNotEmpty
                      ? Image.network(
                    store.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.store, size: 18, color: Colors.grey),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center( // 🚀 'const' kaldırıldı
                        child: SizedBox(
                          width: 10,
                          height: 10,
                          child: PlatformWidgets.loader(
                            strokeWidth: 1.5,
                            radius: 5,
                          ),
                        ),
                      );
                      },
                  )
                      : const Icon(Icons.store, size: 18, color: Colors.grey),
                ),
              ),


              const SizedBox(width: 10),

              // INFO
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME + RATING (AYNI SATIR)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (store.overallRating != null &&
                            store.overallRating! > 0) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.star,
                              color: Colors.amber, size: 15),
                          Text(
                            store.overallRating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 3),

                  ],
                ),
              ),

              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 22, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
