import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bildirimler')),
      body: notificationsAsync.when(
        data: (notifications) => ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final item = notifications[index];
            return ListTile(
              title: Text(item.title),
              subtitle: Text(item.body),
              trailing: item.isRead ? null : const Icon(Icons.circle, color: Colors.blue, size: 10),
              onTap: () {
                // Backend'e "okundu" (read) isteği atacak fonksiyonu çağır
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}