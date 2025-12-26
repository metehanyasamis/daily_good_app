import 'dart:io';

import 'package:dio/dio.dart';

class ContactMessage {
  final String subject; // List<String> yerine String yapıldı
  final String? orderId;
  final String? message;
  final List<File> attachments;

  ContactMessage({
    required this.subject, // Tekil hale getirildi
    this.orderId,
    this.message,
    this.attachments = const [],
  });

  FormData toFormData() {
    final formData = FormData();

    // 🎯 DÜZELTME: Liste döngüsünü kaldır, tekil string gönder
    // Backend dokümanında 'subject[]' değil sadece 'subject' yazıyor.
    formData.fields.add(MapEntry('subject', subject));

    if (orderId != null && orderId!.isNotEmpty) {
      formData.fields.add(MapEntry('order_id', orderId!));
    }

    if (message != null && message!.isNotEmpty) {
      formData.fields.add(MapEntry('message', message!));
    }

    // Fotoğraflar için 'attachments[]' kullanımı dokümanla uyumlu görünüyor.
    for (final file in attachments) {
      formData.files.add(
        MapEntry(
          'attachments[]',
          MultipartFile.fromFileSync(file.path),
        ),
      );
    }

    return formData;
  }
}