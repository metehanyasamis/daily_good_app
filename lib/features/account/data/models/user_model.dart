
import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String phone;

  final bool isEmailVerified;
  final bool isPhoneVerified;

  final String? birthDate;
  final double? latitude;
  final double? longitude;

  final double? locationLat;
  final double? locationLng;

  final String? fcmToken;
  final String? createdAt;
  final String? updatedAt;

  final String? token;
  final UserStatistics? statistics;

  UserModel({
    required this.id,
    required this.phone,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.birthDate,
    this.latitude,
    this.longitude,
    this.locationLat,
    this.locationLng,
    this.fcmToken,
    this.createdAt,
    this.updatedAt,
    this.token,
    this.statistics,
  });


  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    print("🛠 [RAW_JSON] email_verified_at: ${json['email_verified_at']}");


    // 1. ADIM: Önce verinin nerede olduğunu bul (customer içinde mi değil mi)
    final Map<String, dynamic> data = json.containsKey('customer')
        ? json['customer']
        : json;

    // 2. ADIM: Doğrulama kontrolünü 'data' üzerinden yap ve bir değişkene ata
    final bool emailCheck = data["email_verified_at"] != null &&
        data["email_verified_at"].toString().toLowerCase() != "null" &&
        data["email_verified_at"].toString().isNotEmpty;

    final bool phoneCheck = data["phone_verified_at"] != null &&
        data["phone_verified_at"].toString().toLowerCase() != "null" &&
        data["phone_verified_at"].toString().isNotEmpty;

    // --- TEMİZ LOGLAR ---
    debugPrint("--------------------------------------------------");
    debugPrint("📧 [MODEL_CHECK] email_verified_at: ${data["email_verified_at"]}");
    debugPrint("✅ [MODEL_RESULT] Sonuç: E-posta Onaylı mı? -> $emailCheck");
    debugPrint("--------------------------------------------------");

    final String? extractedToken = token ?? json['token'];
    final location = data["location"];
    final statsJson = data["statistics"];

    // 3. ADIM: Kullanıcıyı oluştururken yukarıdaki 'emailCheck' sonucunu kullan
    return UserModel(
      id: data["id"]?.toString() ?? "",
      phone: data["phone"]?.toString() ?? "",
      firstName: data["first_name"],
      lastName: data["last_name"],
      fullName: data["full_name"],
      email: data["email"],
      birthDate: data["birth_date"]?.toString(),

      // 🔥 Burası çok önemli: Yukarıda hesapladığımız sonucu buraya veriyoruz
      isEmailVerified: emailCheck,
      isPhoneVerified: phoneCheck,

      latitude: data["latitude"] != null ? double.tryParse(data["latitude"].toString()) : null,
      longitude: data["longitude"] != null ? double.tryParse(data["longitude"].toString()) : null,
      locationLat: location != null ? (location["lat"]?.toDouble()) : null,
      locationLng: location != null ? (location["lng"]?.toDouble()) : null,
      fcmToken: data["fcm_token"],
      createdAt: data["created_at"],
      updatedAt: data["updated_at"],
      token: extractedToken,
      statistics: statsJson != null ? UserStatistics.fromJson(statsJson) : null,
    );
  }


  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "full_name": fullName,
    "email": email,
    "phone": phone,
    "birth_date": birthDate,
    "isEmailVerified": isEmailVerified,
    "isPhoneVerified": isPhoneVerified,
    "latitude": latitude,
    "longitude": longitude,
    "location": {
      "lat": locationLat,
      "lng": locationLng,
    },
    "fcm_token": fcmToken,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "token": token,
    "statistics": statistics?.toJson(),
  };

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phone,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    String? birthDate,
    double? latitude,
    double? longitude,
    double? locationLat,
    double? locationLng,
    String? fcmToken,
    String? createdAt,
    String? updatedAt,
    String? token,
    UserStatistics? statistics,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      birthDate: birthDate ?? this.birthDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLat: locationLat ?? this.locationLat,
      locationLng: locationLng ?? this.locationLng,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
      statistics: statistics ?? this.statistics,
    );
  }
}


// 📊 Backend'deki "statistics" yapısını karşılayan yardımcı sınıf
class UserStatistics {
  final int totalPackages;
  final double totalSavings;
  final double carbonFootprint;

  UserStatistics({
    required this.totalPackages,
    required this.totalSavings,
    required this.carbonFootprint,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalPackages: json['total_packages_purchased'] ?? 0,
      totalSavings: (json['total_savings'] ?? 0).toDouble(),
      carbonFootprint: (json['carbon_footprint_kg'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "total_packages_purchased": totalPackages,
    "total_savings": totalSavings,
    "carbon_footprint_kg": carbonFootprint,
  };
}