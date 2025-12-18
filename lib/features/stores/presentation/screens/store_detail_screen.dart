import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/store_detail_provider.dart';
import '../widgets/store_details_content.dart';
import '../widgets/store_review_section.dart';
import '../widgets/store_working_hours_section.dart';
import '../../data/model/working_hours_mapper.dart';

class StoreDetailScreen extends ConsumerWidget {
  final String storeId;

  const StoreDetailScreen({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🔥 DOĞRU KULLANIM (family!)
    final state = ref.watch(storeDetailProvider(storeId));

    if (state.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null) {
      return Scaffold(
        body: Center(child: Text("Hata: ${state.error}")),
      );
    }

    final store = state.detail;
    if (store == null) {
      return const Scaffold(
        body: Center(child: Text("Mağaza bulunamadı")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mağaza Detayı"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StoreDetailsContent(storeDetail: store),

            const SizedBox(height: 12),

            if (store.workingHours != null &&
                store.workingHours!.days.isNotEmpty)
              StoreWorkingHoursSection(
                hours: store.workingHours!.toUiList(),
              ),

            const SizedBox(height: 16),

            // 🔥 review section storeId ile çalışır
            StoreReviewSection(storeId: storeId),
          ],
        ),
      ),
    );
  }
}
