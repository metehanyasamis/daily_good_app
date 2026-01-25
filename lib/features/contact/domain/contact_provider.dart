import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/contact_repository.dart';
import '../data/contact_message_model.dart';

final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ContactRepository(dio);
});

final sendContactMessageProvider =
FutureProvider.family<void, ContactMessage>((ref, msg) async {
  final repo = ref.read(contactRepositoryProvider);
  await repo.sendMessage(msg);
});
