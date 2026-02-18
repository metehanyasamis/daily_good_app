import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../location/domain/address_notifier.dart';
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
    bool forceRefresh = false,
  }) async {
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

      // 🔥 KRİTİK DÜZELTME: Veri gelene kadar sayfa kapanmış olabilir.
      // Eğer notifier kapandıysa (dispose), state güncellemeye çalışma!
      if (!mounted) return;

      state = state.copyWith(
        sectionProducts: sections,
        loadingSections: { for (var s in HomeSection.values) s: false },
      );
    } catch (e) {
      // 🔥 Buraya da eklemelisin çünkü hata aldığında da state güncelliyorsun.
      if (!mounted) return;

      state = state.copyWith(
        loadingSections: { for (var s in HomeSection.values) s: false },
      );
    }
  }
}



final homeStateProvider = StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  // 📍 ADRESİ İZLE: Adres her değiştiğinde bu provider tetiklenir.
  final address = ref.watch(addressProvider);
  final repo = ref.watch(productRepositoryProvider);

  // Notifier'ı oluştur ve YENİ konumla veriyi hemen çek
  final notifier = HomeStateNotifier(repo);

  // 🚀 Adres değiştiği an 30 saniye kilidine takılmadan (forceRefresh: true) veriyi tazele
  notifier.loadHome(
      latitude: address.lat,
      longitude: address.lng,
      forceRefresh: true
  );

  return notifier;
});
