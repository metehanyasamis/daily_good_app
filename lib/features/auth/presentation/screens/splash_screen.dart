import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../domain/providers/auth_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // LOGO ANIMASYONU
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Başlangıç işlemlerini başlat
    Future.microtask(_startupSequence);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // STARTUP FLOW
  // ----------------------------------------------------------
  Future<void> _startupSequence() async {
    debugPrint("🚀 [Splash] Başlatılıyor...");

    // 1) AppState'i SharedPreferences'tan yükle
    await ref.read(appStateProvider.notifier).load();

    // 2) Token kontrolü
    final token = await PrefsService.readToken();
    debugPrint("🔑 [Splash] Token = $token");

    if (token != null && token.isNotEmpty) {
      debugPrint("🔐 [Splash] Token bulundu → /me çağrılıyor...");
      await ref.read(authNotifierProvider.notifier).loadUserFromToken();
    } else {
      debugPrint("🟡 [Splash] Token yok → anonymous user");
    }

    // Yönlendirme YOK – tamamen GoRouter redirect devralıyor
    debugPrint("🎯 [Splash] Hazır → GoRouter redirect devralacak");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.dark,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/logos/whiteLogo.png',
              height: size.height * 0.35,
            ),
          ),
        ),
      ),
    );
  }
}
