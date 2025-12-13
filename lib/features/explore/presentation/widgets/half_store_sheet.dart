import 'package:flutter/material.dart';

import '../../../stores/data/model/store_summary.dart';

class HalfStoreSheet extends StatelessWidget {
  final StoreSummary store;
  final VoidCallback onStoreTap;

  const HalfStoreSheet({
    super.key,
    required this.store,
    required this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onStoreTap,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage:
                      NetworkImage(store.imageUrl),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(store.address,
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
