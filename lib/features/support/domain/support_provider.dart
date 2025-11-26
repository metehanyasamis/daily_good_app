// lib/features/support/domain/support_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/support_repository.dart';
import '../data/support_message_model.dart';

final supportRepositoryProvider = Provider((ref) => SupportRepository());

final sendSupportMessageProvider = FutureProvider.family<void, SupportMessage>((ref, msg) async {
  final repo = ref.read(supportRepositoryProvider);
  await repo.sendSupportMessage(msg);
});
