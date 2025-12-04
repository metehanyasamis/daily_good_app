import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_detail_state.dart';
import '../../data/repository/store_repository.dart';
import '../../../review/data/repository/review_repository.dart';

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
      final detail = await storeRepo.getStoreDetail(storeId);
      final reviews = await storeRepo.getStoreReviews(storeId);

      state = state.copyWith(
        detail: detail,
        reviews: reviews,
        myReviewId: null,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        loading: false,
      );
    }
  }

  Future<void> refreshReviews(String storeId) async {
    final reviews = await storeRepo.getStoreReviews(storeId);
    state = state.copyWith(reviews: reviews);
  }
}
