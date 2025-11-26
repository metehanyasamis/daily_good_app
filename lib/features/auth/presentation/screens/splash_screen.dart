import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/prefs_service.dart';
import '../../../../core/providers/app_state_provider.dart';
import '../../../account/domain/providers/user_notifier.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();

    // ✅ user restore işlemi — asenkron ama beklemeden başlat
    Future.microtask(() async {
      final userNotifier = ref.read(userNotifierProvider.notifier);
      await userNotifier.init(); // local user yükleniyor
    });

    // ✅ küçük gecikmeyle splash yönlendirmeyi başlat
    Future.delayed(const Duration(milliseconds: 300), _initState);
  }

  Future<void> _initState() async {
    if (_initialized) return;
    _initialized = true;

    // logo animasyon süresi
    await Future.delayed(const Duration(seconds: 2));

    try {
      // 🔹 Prefs’ten verileri oku
      final token = await PrefsService.readToken();
      final seenProfile = await PrefsService.getHasSeenProfileDetails();
      final seenOnboarding = await PrefsService.getHasSeenOnboarding();

      debugPrint(
        '✅ SplashCheck → token=$token | seenProfile=$seenProfile | seenOnboarding=$seenOnboarding',
      );

      // 🔹 app state güncelle
      final appStateNotifier = ref.read(appStateProvider.notifier);
      if (token != null) appStateNotifier.setLoggedIn(true);
      if (seenProfile) appStateNotifier.setProfileCompleted(true);
      if (seenOnboarding) appStateNotifier.setOnboardingSeen(true);

      if (!mounted) return;

      // 🔹 300ms gecikme → GoRouter hazır olana kadar beklet
      Future.delayed(const Duration(seconds: 2), () {
        if(mounted) context.go('/home'); // dummy, router redirect gerçek yeri bulur
      });

    } catch (e, s) {
      debugPrint('❌ Splash init error: $e');
      debugPrint('$s');
      if (mounted) context.go('/login'); // fallback
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7EDC8A), Color(0xFF3E8D4E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/logos/whiteLogo.png',
              height: size.height * 0.35,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
