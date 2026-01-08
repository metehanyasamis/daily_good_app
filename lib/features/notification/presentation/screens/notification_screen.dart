import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationListProvider);
    final localNotifications = ref.watch(localNotificationsProvider);

    // Badge sıfırla (ekran açılınca)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationBadgeProvider.notifier).state = 0;
    });

    return Scaffold(
      backgroundColor: AppColors.background,

      // 🟢 APPBAR (Sepet ile birebir stil)
      appBar: AppBar(
        // 🚀 MERKEZİ TEMADAN TÜM AYARLARI ÇEK
        backgroundColor: AppTheme.greenAppBarTheme.backgroundColor,
        foregroundColor: AppTheme.greenAppBarTheme.foregroundColor,
        systemOverlayStyle: AppTheme.greenAppBarTheme.systemOverlayStyle, // Şebekeleri beyaz yapar
        iconTheme: AppTheme.greenAppBarTheme.iconTheme, // İkonları otomatik beyaz yapar
        titleTextStyle: AppTheme.greenAppBarTheme.titleTextStyle,
        centerTitle: AppTheme.greenAppBarTheme.centerTitle,

        title: const Text('Bildirimler'),

        // Geri butonu için artık 'color: Colors.white' yazmana gerek yok, temadan alır.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Hata: $err")),
        data: (backendNotifications) {
          final combinedList = [
            ...localNotifications,
            ...backendNotifications,
          ];

          if (combinedList.isEmpty) {
            return _EmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: combinedList.length,
            itemBuilder: (context, index) {
              final item = combinedList[index];
              return _NotificationCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isUnread = !(item.isRead ?? true);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? AppColors.primaryDarkGreen.withOpacity(0.4)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔔 ICON
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: AppColors.primaryDarkGreen,
              size: 22,
            ),
          ),

          const SizedBox(width: 12),

          // 📝 TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // 🟢 OKUNMAMIŞ NOKTA
          if (isUnread)
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.primaryDarkGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.notifications_off_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            "Henüz bildirim yok",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
