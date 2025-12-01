import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../../core/theme/app_theme.dart';
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

    // ---------------------------
    // LOGO ANIMASYONU
    // ---------------------------
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Splash flow'u başlat
    Future.microtask(_handleStartup);
  }

  @override
  void dispose() {
    _controller.dispose();   // 🔥 ANİMASYON TİCKER'INI YOK EDİYOR
    super.dispose();
  }

  // ----------------------------------------------------------
  // SPLASH FLOW
  // ----------------------------------------------------------
  Future<void> _handleStartup() async {
    debugPrint("🚀 [Splash] Başlatılıyor...");

    await Future.delayed(const Duration(milliseconds: 800));

    final app = ref.read(appStateProvider);
    final token = await PrefsService.readToken();

    debugPrint("🔍 [Splash] isLoggedIn=${app.isLoggedIn}");
    debugPrint("🔑 [Splash] Token=$token");

    // 1) Hiç login olmamış → login ekranı
    if (!app.isLoggedIn) {
      debugPrint("❌ [Splash] isLoggedIn=false → login");
      context.go('/login');
      return;
    }

    // 2) Login olmuş ama token yok → YENİ KULLANICI
    if (app.isLoggedIn && (token == null || token.isEmpty)) {
      debugPrint("🆕 [Splash] Yeni kullanıcı → profil doldurma akışına gidiyor");
      context.go('/profileDetail');
      return;
    }

    // 3) Eski kullanıcı → /me kontrolü
    debugPrint("🔐 [Splash] isLoggedIn=true → /me ile kullanıcı yükleniyor");

    final auth = ref.read(authNotifierProvider.notifier);
    final ok = await auth.loadUserFromToken();

    if (!ok) {
      debugPrint("⚠️ [Splash] /me başarısız → login");
      context.go('/login');
      return;
    }

    debugPrint("🎉 [Splash] /me başarılı → home");
    context.go('/home');
  }




  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.dark, // Theme’den gradient
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
