// Repository Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider); // Senin mevcut dio provider'ın
  return NotificationRepository(dio);
});

// Bildirim Listesi FutureProvider (Artık repository'yi kullanıyor)
final notificationListProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

// 1. Manuel gelen bildirimleri tutacak liste (Backend düzelene kadar)
final localNotificationsProvider = StateProvider<List<NotificationModel>>((ref) => []);

// 2. Okunmamış bildirim sayısı (Badge için)
final notificationBadgeProvider = StateProvider<int>((ref) => 0);