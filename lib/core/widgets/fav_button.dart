import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/favorites/providers/favorites_provider.dart';

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
    final fav = ref.watch(favoritesProvider);

    final isFav = isStore
        ? fav.favoriteShops.any((s) => s.id == id)
        : fav.favoriteProducts.any((p) => p.id == id);

    return GestureDetector(
      onTap: () {
        if (isStore) {
          ref.read(favoritesProvider.notifier).toggleStoreFavorite(id);
        } else {
          ref.read(favoritesProvider.notifier).toggleProductFavorite(id);
        }
      },
      child: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : Colors.grey,
      ),
    );
  }
}

