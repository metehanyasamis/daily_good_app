import '../../../review/domain/models/review_model.dart';
import '../../data/model/store_detail_model.dart';

class StoreDetailState {
  final StoreDetailModel? detail;
  final List<ReviewModel> reviews;
  final String? myReviewId;
  final bool loading;
  final String? error;

  StoreDetailState({
    this.detail,
    this.reviews = const [],
    this.myReviewId,
    this.loading = false,
    this.error,
  });

  StoreDetailState copyWith({
    StoreDetailModel? detail,
    List<ReviewModel>? reviews,
    String? myReviewId,
    bool? loading,
    String? error,
  }) {
    return StoreDetailState(
      detail: detail ?? this.detail,
      reviews: reviews ?? this.reviews,
      myReviewId: myReviewId ?? this.myReviewId,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
