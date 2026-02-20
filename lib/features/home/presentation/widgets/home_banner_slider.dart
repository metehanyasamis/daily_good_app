import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/platform_widgets.dart';
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
    final bannerState = ref.watch(bannerProvider);
    final w = MediaQuery.of(context).size.width;

    debugPrint('🏠 [BANNER_SLIDER] build() - isLoading: ${bannerState.isLoading}, banners: ${bannerState.banners.length}, error: ${bannerState.error}');

    ref.listen(bannerProvider, (previous, next) {
      if (previous?.banners.isEmpty == true && next.banners.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _initializeController(next.banners.length);
            setState(() {});
          }
        });
      }
    });

    // ⚠️ ÖNEMLİ: Banner yoksa veya hata varsa TAMAMEN GİZLE (hiçbir şey gösterme)
    if (bannerState.banners.isEmpty) {
      // Loading durumunda bile maksimum 5 saniye göster, sonra gizle
      if (bannerState.isLoading && bannerState.error == null) {
        // İlk 5 saniye loading göster
        return FutureBuilder(
          future: Future.delayed(const Duration(seconds: 5)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // 5 saniye sonra hala banner yoksa gizle
              debugPrint('🏠 [BANNER_SLIDER] Timeout - hiding banner area after 5 seconds');
              return const SizedBox.shrink();
            }
            // İlk 5 saniye loading göster
            return SizedBox(
              height: 180,
              width: w,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryDarkGreen,
                ),
              ),
            );
          },
        );
      }
      // Banner yoksa veya hata varsa tamamen gizle
      debugPrint('🏠 [BANNER_SLIDER] No banners to display - hiding completely');
      return const SizedBox.shrink();
    }

    final banners = bannerState.banners;
    final bannerCount = banners.length;

    // Controller'ı hemen initialize et (eğer yoksa ve banner varsa)
    if (_controller == null && bannerCount > 0) {
      _initializeController(bannerCount);
    }

    return Column(
      mainAxisSize: MainAxisSize.min, // Overflow'u önlemek için
      children: [
        ClipRect(
          child: SizedBox(
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
                      itemCount: bannerCount > 0 ? bannerCount * 100 : 0,
                      onPageChanged: (idx) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            virtualPage = idx;
                            setState(() => _currentIndex = idx % bannerCount);
                          }
                        });
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

                            return AnimatedBuilder(
                              animation: _controller!,
                              builder: (context, _) {
                                double scale = 1.0;

                                if (_controller!.hasClients && _controller!.position.haveDimensions) {
                                  final page = _controller!.page ?? virtualPage.toDouble();
                                  final diff = (page - index).abs().clamp(0.0, 1.0);
                                  scale = 1 - (diff * 0.08);
                                }

                                return Transform.scale(
                                  scale: scale,
                                  child: Padding(
                                    // ✅ margin yerine burada küçük spacing (istersen 0 yap)
                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: DecoratedBox(
                                        // ✅ image gelene kadar da boşluk "beyaz" görünmesin
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryLightGreen.withValues(alpha: 0.08),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.08),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: SizedBox(
                                          height: 180,
                                          width: double.infinity,
                                          child: CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.fill, // ✅ tam oturması için (cover kırpabilir)
                                            placeholder: (context, url) => Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: PlatformWidgets.loader(
                                                  strokeWidth: 2,
                                                  color: AppColors.primaryDarkGreen,
                                                  radius: 12,
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) => Center(
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: AppColors.primaryDarkGreen.withValues(alpha: 0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );

                          },
                        );
                      },
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 8),

        // 🔹 Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
