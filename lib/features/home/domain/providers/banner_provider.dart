import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/banner_model.dart';
import '../../data/repository/banner_repository.dart';

class BannerState {
  final List<BannerModel> banners;
  final bool isLoading;
  final String? error;

  BannerState({
    required this.banners,
    required this.isLoading,
    this.error,
  });

  BannerState copyWith({
    List<BannerModel>? banners,
    bool? isLoading,
    String? error,
  }) {
    return BannerState(
      banners: banners ?? this.banners,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class BannerNotifier extends StateNotifier<BannerState> {
  final BannerRepository _repository;
  DateTime? _lastFetchTime;
  static const _cacheDuration = Duration(minutes: 5);

  BannerNotifier(this._repository)
      : super(BannerState(banners: [], isLoading: false));

  Future<void> loadBanners({bool forceRefresh = false}) async {
    // 🚀 Cache kontrolü: Eğer son 5 dakika içinde yüklendiyse ve force refresh değilse, tekrar yükleme
    if (!forceRefresh &&
        _lastFetchTime != null &&
        state.banners.isNotEmpty &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      debugPrint('🏠 [BANNER_PROVIDER] Banners already cached, skipping...');
      return;
    }

    debugPrint('🏠 [BANNER_PROVIDER] Loading banners...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final banners = await _repository.fetchBanners(
        sortBy: 'order',
        sortOrder: 'asc',
        perPage: 50,
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          debugPrint('⏱️ [BANNER_PROVIDER] Timeout after 8 seconds - returning empty list');
          return <BannerModel>[];
        },
      );

      _lastFetchTime = DateTime.now();
      debugPrint('✅ [BANNER_PROVIDER] Loaded ${banners.length} banners');
      
      // ⚠️ ÖNEMLİ: Her durumda loading state'i false yap
      state = state.copyWith(
        banners: banners,
        isLoading: false,
        error: banners.isEmpty ? 'No banners found' : null,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ [BANNER_PROVIDER] Error loading banners: $e');
      debugPrint('📦 [BANNER_PROVIDER] StackTrace: $stackTrace');
      // ⚠️ ÖNEMLİ: Hata olsa bile loading state'i false yap, yoksa indicator sürekli döner
      state = state.copyWith(
        banners: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final bannerProvider =
    StateNotifierProvider<BannerNotifier, BannerState>((ref) {
  return BannerNotifier(ref.read(bannerRepositoryProvider));
});
