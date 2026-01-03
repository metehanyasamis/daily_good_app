import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/domain/providers/cart_provider.dart';
import '../../domain/providers/order_provider.dart';

class OrderSuccessScreen extends ConsumerStatefulWidget {
  /// Ödeme tamamlandıktan sonra gelen sipariş ID'si
  final String? orderId;

  const OrderSuccessScreen({super.key, this.orderId});

  @override
  ConsumerState<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends ConsumerState<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    // 🧹 ÖDEME TAMAMLANDI → SEPETİ TEMİZLE
    // CartController'da yaptığımız yeni "kilitli" sistem sayesinde
    // burada güvenle çağırabiliriz, 404 hatası almayız.
    Future.microtask(() {
      ref.read(cartProvider.notifier).clearCart();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // 🔹 2.5 saniye sonra sipariş takibine yönlendir
    Timer(const Duration(seconds: 2, milliseconds: 500), () {
      if (mounted) {
        // widget.orderId zaten String? olarak tanımlı olmalı
        final targetId = widget.orderId ?? "last";
        ref.invalidate(activeOrdersProvider);
        context.go('/order-tracking');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDarkGreen,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Başarı İkonu
                  Transform.scale(
                    scale: _scale.value,
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Başlık
                  Opacity(
                    opacity: _fade.value,
                    child: const Text(
                      "Siparişin Alındı!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Alt Bilgi
                  Opacity(
                    opacity: _fade.value,
                    child: const Text(
                      "Sipariş takip ekranına yönlendiriliyorsun...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Yükleniyor İndikatörü
                  Opacity(
                    opacity: _fade.value,
                    child: Column(
                      children: const [
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator.adaptive(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3.2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Hazırlanıyor...",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}