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

  BannerNotifier(this._repository)
      : super(BannerState(banners: [], isLoading: false));

  Future<void> loadBanners() async {
    debugPrint('🏠 [BANNER_PROVIDER] Loading banners...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final banners = await _repository.fetchBanners(
        sortBy: 'order',
        sortOrder: 'asc',
        perPage: 50,
      );

      debugPrint('✅ [BANNER_PROVIDER] Loaded ${banners.length} banners');
      state = state.copyWith(
        banners: banners,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('❌ [BANNER_PROVIDER] Error loading banners: $e');
      state = state.copyWith(
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
