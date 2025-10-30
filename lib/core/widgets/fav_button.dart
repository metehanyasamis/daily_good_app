import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'animated_toast.dart';

/// 💚 Ortak Favori Butonu (toast + animasyon entegre)
class FavButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onToggle;
  final double size;
  final BuildContext context; // 🔹 context parametresi eklendi

  const FavButton({
    super.key,
    required this.isFav,
    required this.onToggle,
    required this.context,
    this.size = 40,
  });

  @override
  State<FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<FavButton>
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _animate();
        widget.onToggle();

        // 💬 yeşil gradientli özel toast
        showAnimatedToast(
          widget.context,
          widget.isFav
              ? 'Favorilerden kaldırıldı'
              : 'Favorilere eklendi 🤍',
        );
      },
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
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
            widget.isFav ? Icons.favorite : Icons.favorite_border,
            color: AppColors.primaryDarkGreen,
            size: widget.size * 0.55,
          ),
        ),
      ),
    );
  }
}
