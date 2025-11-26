import 'dart:io';

class SupportMessage {
  final String topic;
  final String? orderId;
  final String? message;
  final String name;
  final String phone;
  final String email;

  final List<File> photos;

  SupportMessage({
    required this.topic,
    required this.orderId,
    required this.message,
    required this.name,
    required this.phone,
    required this.email,
    this.photos = const [],
  });
}
