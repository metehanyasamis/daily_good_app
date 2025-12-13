// lib/features/explore/domain/providers/explore_store_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../location/domain/address_notifier.dart';
import '../../../stores/data/model/store_summary.dart';
import '../../../stores/data/repository/store_repository.dart';
import 'explore_state_provider.dart';

final exploreStoreProvider =
FutureProvider.autoDispose<List<StoreSummary>>((ref) async {
  final address = ref.watch(addressProvider);
  final explore = ref.watch(exploreStateProvider);

  if (!address.isSelected) return [];

  final repo = ref.watch(storeRepositoryProvider);

  return repo.getStoresByLocation(
    latitude: address.lat,
    longitude: address.lng,
    sortBy: explore.sort.name,
    category: explore.category.name == 'all'
        ? null
        : explore.category.name,
    perPage: 50,
  );
});
