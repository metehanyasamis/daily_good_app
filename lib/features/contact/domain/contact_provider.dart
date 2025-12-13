// lib/features/contact/domain/contact_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/contact_repository.dart';
import '../data/contact_message_model.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final api = ref.read(apiClientProvider);
  return ContactRepository(api);
});

final sendContactMessageProvider =
FutureProvider.family<void, ContactMessage>((ref, msg) async {
  final repo = ref.read(contactRepositoryProvider);
  await repo.sendMessage(msg);
});
