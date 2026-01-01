class NotificationModel {
  final String id;
  final String title;
  final String body;
  final bool isRead; // Bu alanın burada tanımlı olduğundan emin olun
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  // Bu metot provider'daki hatayı çözecek
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['message'] ?? '',
      isRead: json['read_at'] != null, // read_at doluysa okunmuş demektir
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}