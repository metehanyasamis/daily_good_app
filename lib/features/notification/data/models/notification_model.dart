class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String status;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // 🎯 Dökümanda okundu bilgisi için "read" boolean veya "read_at" tarih alanı olabilir.
    // İkisini de kapsayan sağlam mantık:
    final bool readStatus = json['read'] == true ||
        json['read_at'] != null ||
        json['is_read'] == true;

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Bildirim',
      // 🎯 Backend bazen 'message' bazen 'body' gönderir, ikisini de kontrol ediyoruz:
      body: json['message'] ?? json['body'] ?? '',
      isRead: readStatus,
      // 🎯 Dökümanda 'pending', 'sent', 'failed' statüleri var:
      status: json['status']?.toString() ?? 'sent',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // UI'da kolaylık sağlaması için copyWith metodu (Okundu işaretlemek için)
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      status: status,
      createdAt: createdAt,
    );
  }
}