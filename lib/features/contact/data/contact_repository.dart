// lib/features/contact/data/contact_repository.dart

import 'dart:convert';
import '../../../core/network/api_client.dart';
import 'contact_message_model.dart';

class ContactRepository {
  final ApiClient api;

  ContactRepository(this.api);

  Future<void> sendMessage(ContactMessage msg) async {
    final body = {
      "subject": msg.subjects, // array<string>
      if (msg.orderId != null) "order_id": msg.orderId,
      if (msg.message != null && msg.message!.isNotEmpty)
        "message": msg.message,
    };

    final res = await api.post(
      "/customer/contact",
      body: body,
    );

    final decoded = jsonDecode(res.body);
    if (decoded["success"] != true) {
      throw Exception(decoded["message"] ?? "Contact gönderilemedi");
    }
  }
}
