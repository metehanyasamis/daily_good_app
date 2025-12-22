import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/favorites/domain/favorites_notifier.dart';
import '../theme/app_theme.dart';

/// Universal FavButton
/// - Provide either `item` (model with .id) OR `id` (String).
/// - If using `item`, optional isStore will be inferred if item has `isStore` or via param.
/// - Animated scale + circular white background + shadow.
/// - Calls notifier.toggleStore(id) or toggleProduct(id) depending on isStore.
class FavButton extends ConsumerStatefulWidget {
  final dynamic item;
  final String? id;
  final bool? isStore; // optional override
  final double size;
  final VoidCallback? onChanged;

  const FavButton({
    super.key,
    this.item,
    this.id,
    this.isStore,
    this.size = 40,
    this.onChanged,
  }) : assert(item != null || id != null, 'Either item or id must be provided');

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
      duration: const Duration(milliseconds: 280),
    );

    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _resolveId() {
    if (widget.id != null && widget.id!.isNotEmpty) return widget.id!;
    try {
      final dynamic it = widget.item;
      final dynamic maybeId = it?.id ?? it?.ID ?? it?.storeId ?? it?.productId;
      if (maybeId != null) return maybeId.toString();
    } catch (_) {}
    return null;
  }

  bool _resolveIsStore() {
    if (widget.isStore != null) return widget.isStore!;
    // try to infer from item shape
    try {
      final it = widget.item;
      if (it == null) return false;
      // if item has 'isStore' or 'store' prop, treat as store
      if ((it as dynamic).runtimeType.toString().toLowerCase().contains('store')) {
        return true;
      }
      // fallback: if item has brand field -> product likely
    } catch (_) {}
    return false;
  }

  bool _isFavoriteFromState(String id, bool isStore) {
    final favState = ref.watch(favoritesProvider);
    if (isStore) return favState.storeIds.contains(id);
    return favState.productIds.contains(id);
  }

  Future<void> _toggleFavorite(String id, bool isStore) async {
    final notifier = ref.read(favoritesProvider.notifier);
    if (isStore) {
      await notifier.toggleStore(id);
    } else {
      await notifier.toggleProduct(id);
    }
    widget.onChanged?.call();
  }

  Future<void> _animate() async {
    try {
      await _controller.forward(from: 0.0);
      await _controller.reverse();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final resolvedId = _resolveId();
    final inferredIsStore = _resolveIsStore();
    final isStore = widget.isStore ?? inferredIsStore;

    // 🔍 BUILD SIRASINDA DURUMU GÖR
    final isFav = _isFavoriteFromState(resolvedId ?? '', isStore);
    debugPrint('🎨 [FAV_BUILD] ID: $resolvedId | isStore: $isStore | isFav: $isFav');

    if (resolvedId == null || resolvedId.isEmpty) {
      return const SizedBox.shrink(); // ID yoksa gizle veya gri göster
    }

    return GestureDetector(
      onTap: () async {
        debugPrint('🖱️ [FAV_CLICK] Tıklandı!');
        debugPrint('   👉 Hedef ID: $resolvedId');
        debugPrint('   👉 Hedef Tip: ${isStore ? "STORE" : "PRODUCT"}');

        await _animate();
        await _toggleFavorite(resolvedId, isStore);
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
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
            color: isFav ? AppColors.primaryDarkGreen : Colors.grey,
            size: widget.size * 0.55,
          ),
        ),
      ),
    );
  }
}