import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final PageController _controller;
  late int virtualPage;
  int _currentIndex = 0;
  Timer? autoTimer;

  final List<String> banners = [
    'assets/images/banner_veggie.jpg',
    'assets/images/banner_food2.jpg',
    'assets/images/banner_food3.jpg',
  ];

  static const _period = Duration(seconds: 5);
  static const _anim = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();

    virtualPage = banners.length * 1000;
    _controller = PageController(
      viewportFraction: 0.96,
      initialPage: virtualPage,
    );

    _startAuto();
  }

  void _startAuto() {
    autoTimer?.cancel();
    autoTimer = Timer.periodic(_period, (_) {
      if (!mounted || !_controller.hasClients) return;
      virtualPage++;
      _controller.animateToPage(
        virtualPage,
        duration: _anim,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseThenResume() {
    autoTimer?.cancel();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startAuto();
    });
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: w,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollStartNotification ||
                  n is UserScrollNotification ||
                  n is ScrollUpdateNotification) {
                _pauseThenResume();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (idx) {
                virtualPage = idx;
                setState(() => _currentIndex = idx % banners.length);
              },
              itemBuilder: (context, index) {
                final real = index % banners.length;

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    double scale = 1.0;

                    if (_controller.hasClients &&
                        _controller.position.haveDimensions) {
                      final page = _controller.page ?? virtualPage.toDouble();
                      scale = (page - index).abs().clamp(0.0, 1.0);
                      scale = 1 - (scale * 0.08);
                    }

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            banners[real],
                            fit: BoxFit.cover,
                            width: w,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 🔹 Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(banners.length, (i) {
            final active = i == _currentIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: active ? 18 : 6,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primaryDarkGreen
                    : AppColors.primaryLightGreen.withOpacity(0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
