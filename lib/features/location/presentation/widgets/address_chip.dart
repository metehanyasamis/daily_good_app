import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/address_notifier.dart';

class AddressChip extends ConsumerWidget {
  final VoidCallback? onTap;

  const AddressChip({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final address = ref.watch(addressProvider);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Text(
              address.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
