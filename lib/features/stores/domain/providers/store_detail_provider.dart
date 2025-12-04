import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../review/data/repository/review_repository.dart';
import '../../../review/domain/models/review_model.dart';
import '../../../review/providers/review_provider.dart';
import '../../data/repository/store_repository.dart';

final storeDetailProvider = StateNotifierProvider.family<
    StoreDetailNotifier, StoreDetailState, String>((ref, id) {
  return StoreDetailNotifier(
    storeRepo: ref.watch(storeRepositoryProvider),
    reviewRepo: ref.watch(reviewRepositoryProvider),
  )..fetch(id);
});

class StoreDetailNotifier extends StateNotifier<StoreDetailState> {
  final StoreRepository storeRepo;
  final ReviewRepository reviewRepo;

  StoreDetailNotifier({
    required this.storeRepo,
    required this.reviewRepo,
  }) : super(StoreDetailState(loading: true));

  Future<void> fetch(String storeId) async {
    state = state.copyWith(loading: true);
    try {
      final detail = await storeRepo.getStoreDetails(storeId);

      // Yeni: backend’den yorumları çek
      final List<ReviewModel> reviews = await storeRepo.getStoreReviews(storeId);

      // Kullanıcının bu mağaza için yorumu var mı?
      String? myReviewId;
      for (var r in reviews) {
        if (r.isMine == true) {
          myReviewId = r.id;
        }
      }

      state = state.copyWith(
        detail: detail,
        reviews: reviews,
        myReviewId: myReviewId,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // Review silindiğinde listeyi yenile
  Future<void> refreshReviews(String storeId) async {
    final reviews = await storeRepo.getStoreReviews(storeId);

    String? myReviewId;
    for (var r in reviews) {
      if (r.isMine == true) {
        myReviewId = r.id;
      }
    }

    state = state.copyWith(
      reviews: reviews,
      myReviewId: myReviewId,
    );
  }
}
