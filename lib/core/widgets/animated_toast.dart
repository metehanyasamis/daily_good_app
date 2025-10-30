import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void showAnimatedToast(
    BuildContext context,
    String message, {
      Color? backgroundColor,
      Duration duration = const Duration(seconds: 2),
    }) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  SchedulerBinding.instance.addPostFrameCallback((_) {
    final entry = OverlayEntry(
      builder: (_) => _AnimatedToast(
        message: message,
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      if (entry.mounted) entry.remove();
    });
  });
}

class _AnimatedToast extends StatefulWidget {
  final String message;
  final Color? backgroundColor;
  final Duration duration;

  const _AnimatedToast({
    required this.message,
    this.backgroundColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<_AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<_AnimatedToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomOffset = MediaQuery.of(context).padding.bottom + 70;

    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                // 🔹 Eğer özel renk verilmişse gradient yerine düz arka plan uygula
                gradient: widget.backgroundColor == null
                    ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF2A8A49),
                    Color(0xFF4CB96A),
                    Color(0xFF6ABF7C),
                  ],
                  stops: [0.0, 0.5, 1.0],
                )
                    : null,
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      widget.message.replaceAll('✔️', '').trim(),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15.5,
                        height: 1.3,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
