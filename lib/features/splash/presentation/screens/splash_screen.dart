import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_state_provider.dart';

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

    Future.delayed(const Duration(milliseconds: 300), _initState);
  }

  Future<void> _initState() async {
    if (_initialized) return;
    _initialized = true;

    await Future.delayed(const Duration(seconds: 2)); // Logo süresi

    final appState = ref.read(appStateProvider);

    if (appState.isFirstLaunch) {
      ref.read(appStateProvider.notifier).setFirstLaunch(false);
      context.go('/intro');
    } else if (!appState.isLoggedIn) {
      context.go('/login');
    } else if (!appState.hasCompletedProfile) {
      context.go('/profileDetail');
    } else if (!appState.hasSeenOnboarding) {
      context.go('/onboarding');
    } else if (!appState.hasLocationAccess) {
      context.go('/location');
    } else {
      context.go('/home');
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
