import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../product/data/repository/product_repository.dart';
import '../../data/models/home_state.dart';


class HomeStateNotifier extends StateNotifier<HomeState> {
  final ProductRepository repo;
  DateTime? _lastFetchTime;

  HomeStateNotifier(this.repo) : super(HomeState.initial());

  void setCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }

  void setHasActiveOrder(bool value) {
    state = state.copyWith(hasActiveOrder: value);
  }

  Future<void> loadHome({
    required double latitude,
    required double longitude,
    bool forceRefresh = false, // 🔄 Elle çekince (Pull to refresh) kilidi kırmak için
  }) async {
    // ⏱️ ZAMAN KONTROLÜ: Eğer son 30 saniye içinde çekildiyse ve zorlanmıyorsa ÇIK!
    if (!forceRefresh && _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < const Duration(seconds: 30)) {
      debugPrint("🏠 [HOME] İstek reddedildi: Veriler zaten güncel (30sn kuralı).");
      return;
    }

    debugPrint("🏠 [HOME] Gerçekten istek atılıyor...");
    _lastFetchTime = DateTime.now();

    state = state.copyWith(
      loadingSections: { for (var s in HomeSection.values) s: true },
    );

    try {
      final sections = await repo.fetchHomeSections(
        latitude: latitude,
        longitude: longitude,
      );

      state = state.copyWith(
        sectionProducts: sections,
        loadingSections: { for (var s in HomeSection.values) s: false },
      );
    } catch (e) {
      // Hata durumunda loading'i kapatmayı unutma
      state = state.copyWith(
        loadingSections: { for (var s in HomeSection.values) s: false },
      );
    }
  }
}



final homeStateProvider =
StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  return HomeStateNotifier(ref.read(productRepositoryProvider));
});
