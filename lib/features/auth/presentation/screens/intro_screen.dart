import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!_isCompleted) {
      setState(() => _isCompleted = true);
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width - 56;
    final double maxDrag = buttonWidth - 100;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.dark,
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Center(
                    child: Image.asset(
                      'assets/images/intro_image.png',
                      height: size.height * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Hızlı,\nLezzetli,\nHesaplı! 🥣',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      fontSize: 52,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Kalan yiyecekleri ucuza al,\nhem tasarruf et hem dünyayı koru.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),

                  // 🔹 Swipe Button (dokunulmadı)
                  Center(
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // 🔸 Arka plan butonu
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE3FFE7),
                                  Color.lerp(
                                      AppColors.primaryLightGreen,
                                      AppColors.primaryDarkGreen,
                                      _dragPosition / maxDrag)!,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Opacity(
                                opacity:
                                1 - (_dragPosition / maxDrag).clamp(0.0, 1.0),
                                child: const Text(
                                  'Başlayalım',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 🔸 Ok ikonları
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Opacity(
                                opacity:
                                1 - (_dragPosition / maxDrag).clamp(0.0, 1.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chevron_right_rounded,
                                        color: Colors.black.withOpacity(0.4),
                                        size: 30),
                                    Icon(Icons.chevron_right_rounded,
                                        color: Colors.black.withOpacity(0.7),
                                        size: 30),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: Colors.black, size: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 🔸 Sürüklenebilir logo
                          Positioned(
                            left: _dragPosition,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  _dragPosition += details.delta.dx;
                                  if (_dragPosition < 0) _dragPosition = 0;
                                  if (_dragPosition > maxDrag) {
                                    _dragPosition = maxDrag;
                                    _goNext();
                                  }
                                });
                              },
                              onHorizontalDragEnd: (_) {
                                if (_dragPosition < maxDrag * 0.7) {
                                  setState(() => _dragPosition = 0);
                                } else {
                                  _goNext();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 90,
                                width: 90,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/logos/dailyGood_tekSaatLogo.png',
                                    height: 60,
                                    color: AppColors.primaryLightGreen,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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

/*
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!_isCompleted) {
      setState(() => _isCompleted = true);
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double buttonWidth = size.width - 56;
    final double maxDrag = buttonWidth - 100;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF84E08A), Color(0xFF49A05D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 28),
                  Center(
                    child: Image.asset(
                      'assets/images/intro_image.png',
                      height: size.height * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Hızlı,\nLezzetli,\nHesaplı! 🥣',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Kalan yiyecekleri ucuza al,\nhem tasarruf et hem dünyayı koru.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 20,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.06),

                  // 🔹 Swipe Button
                  Center(
                    child: SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          // 🔸 Arka plan butonu
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFE3FFE7),
                                  Color.lerp(const Color(0xFF6ABF7C),
                                      const Color(0xFF3B8B54),
                                      _dragPosition / maxDrag)!,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Opacity(
                                opacity:
                                1 - (_dragPosition / maxDrag).clamp(0.0, 1.0),
                                child: const Text(
                                  'Başlayalım',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 🔸 Ok ikonları (arka planla birlikte kaybolur, ortalanmış)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: Opacity(
                                opacity: 1 - (_dragPosition / maxDrag).clamp(0.0, 1.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.chevron_right_rounded,
                                        color: Colors.black.withOpacity(0.4), size: 30),
                                    Icon(Icons.chevron_right_rounded,
                                        color: Colors.black.withOpacity(0.7), size: 30),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: Colors.black, size: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 🔸 Sürüklenebilir logo
                          Positioned(
                            left: _dragPosition,
                            child: GestureDetector(
                              onHorizontalDragUpdate: (details) {
                                setState(() {
                                  _dragPosition += details.delta.dx;
                                  if (_dragPosition < 0) _dragPosition = 0;
                                  if (_dragPosition > maxDrag) {
                                    _dragPosition = maxDrag;
                                    _goNext();
                                  }
                                });
                              },
                              onHorizontalDragEnd: (_) {
                                if (_dragPosition < maxDrag * 0.7) {
                                  setState(() => _dragPosition = 0);
                                } else {
                                  _goNext();
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 90,
                                width: 90,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/logos/dailyGood_tekSaatLogo.png',
                                    height: 60,
                                    color: Color(0xFF6CCF7F),
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
*/