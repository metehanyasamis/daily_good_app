import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/platform/platform_widgets.dart';
import '../../domain/providers/store_list_provider.dart';
import '../widgets/store_card.dart';

class StoreListScreen extends ConsumerWidget {
  const StoreListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mağazalar"),
        centerTitle: true,
      ),
      body: state.loading
          ? Center(
        child: PlatformWidgets.loader(),
      )
          : state.error != null
          ? Center(child: Text("Hata: ${state.error}"))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: state.stores.length,
        itemBuilder: (_, i) {
          final store = state.stores[i];
          return StoreCard(store: store);
        },
      ),
    );
  }
}
