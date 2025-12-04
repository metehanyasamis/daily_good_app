import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/store_detail_provider.dart';
import '../widgets/store_details_content.dart';
import '../widgets/store_review_section.dart';


class StoreDetailScreen extends ConsumerWidget {
  final String storeId;
  const StoreDetailScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeDetailProvider(storeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mağaza Detayı"),
        centerTitle: true,
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
          ? Center(child: Text("Hata: ${state.error}"))
          : SingleChildScrollView(
        child: Column(
          children: [
            StoreDetailsContent(storeDetail: state.detail!),

            const SizedBox(height: 10),

            StoreReviewSection(storeId: storeId),
          ],
        ),
      ),
    );
  }
}
