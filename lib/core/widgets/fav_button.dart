import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/product/data/models/store_summary.dart';
import '../theme/app_theme.dart';

import '../../features/product/data/models/product_model.dart';

/// 💚 Ortak Favori Butonu
class FavButton extends ConsumerStatefulWidget {
  final dynamic item; // ProductModel veya StoreSummary
  final double size;
  final VoidCallback? onChanged;

  const FavButton({
    super.key,
    required this.item,
    this.size = 40,
    this.onChanged,
  });

  @override
  ConsumerState<FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends ConsumerState<FavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  Future<void> _animate() async {
    try {
      await _controller.forward(from: 0.0);
      await _controller.reverse();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isFavorite(dynamic item) {
    final favorites = ref.watch(favoritesProvider);

    if (item is ProductModel) {
      return favorites.favoriteProducts
          .any((p) => p.id == item.id);
    }

    if (item is StoreSummary) {
      return favorites.favoriteStores
          .any((s) => s.id == item.id);
    }

    return false;
  }

  void _toggleFavorite(dynamic item) {
    final notifier = ref.read(favoritesProvider.notifier);

    if (item is ProductModel) {
      notifier.toggleProduct(item);
    } else if (item is StoreSummary) {
      notifier.toggleStore(item);
    }

    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isFav = _isFavorite(widget.item);

    return GestureDetector(
      onTap: () async {
        await _animate();
        _toggleFavorite(widget.item);
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: AppColors.primaryDarkGreen,
            size: widget.size * 0.55,
          ),
        ),
      ),
    );
  }
}
