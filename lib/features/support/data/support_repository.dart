// lib/features/support/data/support_repository.dart

import 'support_message_model.dart';

class SupportRepository {
  Future<void> sendSupportMessage(SupportMessage msg) async {
    // TODO: Backend geldiğinde burada API veya e-mail servisi olacak
    await Future.delayed(const Duration(milliseconds: 800));
    print("📩 Support Message Sent:");
    print(msg.topic);
    print(msg.orderId);
    print(msg.message);
  }
}
