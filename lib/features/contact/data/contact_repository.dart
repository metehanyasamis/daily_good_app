import 'package:dio/dio.dart';
import 'contact_message_model.dart';

class ContactRepository {
  final Dio dio;

  ContactRepository(this.dio);

  Future<void> sendMessage(ContactMessage msg) async {
    final formData = msg.toFormData();

    final response = await dio.post(
      "/customer/contact",
      data: formData,
    );

    final data = response.data;

    if (data == null || data["success"] != true) {
      throw Exception(data?["message"] ?? "Contact gönderilemedi");
    }
  }
}
