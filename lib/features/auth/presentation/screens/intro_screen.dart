import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/providers/app_state_provider.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen>
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

  Future<void> _goNext() async {
    if (_isCompleted) return;
    setState(() => _isCompleted = true);

    // Uygulama durumunu güncelle
    await ref.read(appStateProvider.notifier).setHasSeenIntro(true);

    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    // Tasarımın güvenli alanları
    const double horizontalPadding = 35.0;
    const double thumbSize = 90.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android: Koyu ikonlar (beyaz arka plan için)
        statusBarBrightness: Brightness.light, // iOS: Koyu ikonlar (beyaz arka plan için)
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryDarkGreen,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.primaryDarkGreen,
          child: FadeTransition(
            opacity: _fadeIn,
            child: SafeArea(
              bottom: false, // Manuel kontrol edeceğiz
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 2), // Üstten esnek boşluk
                    // 1. Görsel Alanı
                    Center(
                      child: Image.asset(
                        'assets/images/intro_image.png',
                        height: size.height * 0.30,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // 2. Metin Alanı
                    Text(
                      'Gıdanı Koru,\nGeleceğine Sahip Çık!',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: AppColors.textProductCardBrandName,
                            height: 1.1,
                            fontWeight: FontWeight.w900,
                            fontSize: size.width * 0.08, // Responsive font
                          ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Kalan yiyecekleri ucuza al,\nhem tasarruf et hem dünyayı koru.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textProductCardBrandName,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // 3. Kaydırma Butonu (Slide to Unlock)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double maxDrag = constraints.maxWidth - thumbSize;

                        return Container(
                          height: thumbSize,
                          margin: EdgeInsets.only(
                            bottom: systemBottomPadding > 0
                                ? systemBottomPadding + 10
                                : 40,
                          ),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            clipBehavior: Clip.none,
                            children: [
                              // Arka Plan Kanalı
                              _buildSliderBackground(maxDrag),

                              // İpucu Okları
                              _buildArrowHints(maxDrag),

                              // Sürüklenebilir Buton (Handle)
                              _buildDraggableThumb(maxDrag),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliderBackground(double maxDrag) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      height: 74,
      // Thumb'dan biraz daha küçük
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE3FFE7),
            Color.lerp(
              AppColors.primaryLightGreen,
              AppColors.primaryDarkGreen,
              _dragPosition / maxDrag,
            )!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Opacity(
          opacity: (1 - (_dragPosition / maxDrag)).clamp(0.0, 1.0),
          child: const Text(
            'Başlayalım',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowHints(double maxDrag) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Opacity(
          opacity: (1 - (_dragPosition / (maxDrag * 0.5))).clamp(0.0, 1.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              return Icon(
                Icons.chevron_right_rounded,
                color: Colors.black.withValues(alpha: 0.3 * (index + 1)),
                size: 28,
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableThumb(double maxDrag) {
    return Positioned(
      left: _dragPosition,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragPosition += details.delta.dx;
            _dragPosition = _dragPosition.clamp(0.0, maxDrag);

            if (_dragPosition >= maxDrag) {
              _goNext();
            }
          });
        },
        onHorizontalDragEnd: (_) {
          if (_dragPosition < maxDrag) {
            setState(() => _dragPosition = 0);
          }
        },
        child: Container(
          height: 90,
          width: 90,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Image.asset(
              'assets/logos/dailyGood_tekSaatLogo.png',
              height: 55,
              color: AppColors.primaryLightGreen,
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
