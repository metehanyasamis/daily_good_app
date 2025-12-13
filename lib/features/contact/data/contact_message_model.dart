// lib/features/contact/data/contact_message_model.dart

import 'dart:io';
import 'package:dio/dio.dart';

class ContactMessage {
  final List<String> subjects;
  final String? orderId;
  final String? message;
  final List<File> attachments;

  ContactMessage({
    required this.subjects,
    this.orderId,
    this.message,
    this.attachments = const [],
  });

  FormData toFormData() {
    final formData = FormData();

    // subject[]
    for (final s in subjects) {
      formData.fields.add(MapEntry('subject[]', s));
    }

    // order_id
    if (orderId != null && orderId!.isNotEmpty) {
      formData.fields.add(MapEntry('order_id', orderId!));
    }

    // message
    if (message != null && message!.isNotEmpty) {
      formData.fields.add(MapEntry('message', message!));
    }

    // attachments[]
    for (final file in attachments) {
      formData.files.add(
        MapEntry(
          'attachments[]',
          MultipartFile.fromFileSync(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }

    return formData;
  }
}
