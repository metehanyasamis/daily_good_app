import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/banner_model.dart';
import '../../domain/providers/banner_provider.dart';

class HomeBannerSlider extends ConsumerStatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  ConsumerState<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends ConsumerState<HomeBannerSlider> {
  PageController? _controller;
  int virtualPage = 0;
  int _currentIndex = 0;
  Timer? autoTimer;

  static const _period = Duration(seconds: 5);
  static const _anim = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    debugPrint('🏠 [BANNER_SLIDER] initState()');
  }

  @override
  void dispose() {
    debugPrint('🏠 [BANNER_SLIDER] dispose()');
    autoTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _initializeController(int bannerCount) {
    if (bannerCount == 0) return;

    if (_controller != null && _controller!.hasClients) {
      return;
    }

    virtualPage = bannerCount * 1000;
    _controller?.dispose();
    _controller = PageController(
      viewportFraction: 0.96,
      initialPage: virtualPage,
    );

    _startAuto(bannerCount);
  }

  void _startAuto(int bannerCount) {
    if (bannerCount == 0) return;

    autoTimer?.cancel();
    autoTimer = Timer.periodic(_period, (_) {
      if (!mounted || _controller == null || !_controller!.hasClients) return;
      virtualPage++;
      _controller!.animateToPage(
        virtualPage,
        duration: _anim,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _pauseThenResume(int bannerCount) {
    autoTimer?.cancel();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _startAuto(bannerCount);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏠 [BANNER_SLIDER] build()');
    final bannerState = ref.watch(bannerProvider);
    final w = MediaQuery.of(context).size.width;

    ref.listen(bannerProvider, (previous, next) {
      if (previous?.banners.isEmpty == true && next.banners.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initializeController(next.banners.length);
          }
        });
      }
    });

    if (bannerState.isLoading && bannerState.banners.isEmpty) {
      return SizedBox(
        height: 180,
        width: w,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDarkGreen,
          ),
        ),
      );
    }

    if (bannerState.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final banners = bannerState.banners;
    final bannerCount = banners.length;

    if (_controller == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeController(bannerCount);
        }
      });
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          width: w,
          child: _controller == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryDarkGreen,
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n is ScrollStartNotification ||
                        n is UserScrollNotification ||
                        n is ScrollUpdateNotification) {
                      _pauseThenResume(bannerCount);
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (idx) {
                      virtualPage = idx;
                      setState(() => _currentIndex = idx % bannerCount);
                    },
                    itemBuilder: (context, index) {
                      final real = index % bannerCount;
                      final banner = banners[real];
                      final imageUrl = BannerModel.normalizeImageUrl(banner.imagePath);

                      return AnimatedBuilder(
                        animation: _controller!,
                        builder: (context, _) {
                          double scale = 1.0;

                          if (_controller!.hasClients &&
                              _controller!.position.haveDimensions) {
                            final page = _controller!.page ?? virtualPage.toDouble();
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
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageUrl.isNotEmpty
                                    ? Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        width: w,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            width: w,
                                            height: 180,
                                            color: AppColors.primaryLightGreen.withValues(alpha: 0.1),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                                color: AppColors.primaryDarkGreen,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: w,
                                            height: 180,
                                            color: AppColors.primaryLightGreen.withValues(alpha: 0.1),
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: w,
                                        height: 180,
                                        color: AppColors.primaryLightGreen.withValues(alpha: 0.1),
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
                                        ),
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
          children: List.generate(bannerCount, (i) {
            final active = i == _currentIndex;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: active ? 18 : 6,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primaryDarkGreen
                    : AppColors.primaryLightGreen.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
