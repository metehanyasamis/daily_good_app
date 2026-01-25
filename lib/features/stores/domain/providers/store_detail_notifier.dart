import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/store_repository.dart';
import '../../../review/data/repository/review_repository.dart';
import 'store_detail_state.dart';

class StoreDetailNotifier extends StateNotifier<StoreDetailState> {
  final StoreRepository storeRepo;
  final ReviewRepository reviewRepo;

  StoreDetailNotifier({
    required this.storeRepo,
    required this.reviewRepo,
  }) : super(StoreDetailState(loading: true));

  Future<void> fetchStore(String storeId) async {
    state = state.copyWith(loading: true);

    try {
      final detail = await storeRepo.getStoreDetail(storeId);
      final reviews = await storeRepo.getStoreReviews(storeId);

      state = state.copyWith(
        detail: detail,
        reviews: reviews,
        loading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        loading: false,
      );
    }
  }
}
