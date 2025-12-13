import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/favorites/domain/favorites_notifier.dart';

class FavButton extends ConsumerWidget {
  final String id;
  final bool isStore;

  const FavButton({
    super.key,
    required this.id,
    this.isStore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(
      favoritesProvider.select((state) {
        return isStore
            ? state.storeIds.contains(id)
            : state.productIds.contains(id);
      }),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final notifier = ref.read(favoritesProvider.notifier);

        if (isStore) {
          notifier.toggleStore(id);
        } else {
          notifier.toggleProduct(id);
        }
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          key: ValueKey(isFav),
          color: isFav ? Colors.redAccent : Colors.grey,
          size: 22,
        ),
      ),
    );
  }
}
