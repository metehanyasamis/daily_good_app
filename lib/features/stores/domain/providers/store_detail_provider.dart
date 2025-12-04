import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../review/providers/review_provider.dart';
import '../../data/repository/store_repository.dart';
import 'store_detail_state.dart';
import 'store_detail_notifier.dart';

final storeDetailProvider =
StateNotifierProvider.family<StoreDetailNotifier, StoreDetailState, String>(
      (ref, storeId) {
    final storeRepo = ref.watch(storeRepositoryProvider);
    final reviewRepo = ref.watch(reviewRepositoryProvider);

    final notifier = StoreDetailNotifier(
      storeRepo: storeRepo,
      reviewRepo: reviewRepo,
    );

    notifier.fetch(storeId);

    return notifier;
  },
);
