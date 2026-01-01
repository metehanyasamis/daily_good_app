
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
// --- TEMİZ LOGLAR ---
    debugPrint("--------------------------------------------------");
    debugPrint("📡 [MODEL_CHECK] User ID: ${json["id"]}");
    debugPrint("📧 [MODEL_CHECK] email_verified_at: ${json["email_verified_at"]}");
    debugPrint("📱 [MODEL_CHECK] phone_verified_at: ${json["phone_verified_at"]}");

    // Boolean değerleri burada hesaplayıp hemen loglayalım
    final bool emailCheck = json["email_verified_at"] != null && json["email_verified_at"].toString().isNotEmpty;
    final bool phoneCheck = json["phone_verified_at"] != null && json["phone_verified_at"].toString().toLowerCase() != "null";

    debugPrint("✅ [MODEL_RESULT] E-posta Onaylı mı?: $emailCheck");
    debugPrint("✅ [MODEL_RESULT] Telefon Onaylı mı?: $phoneCheck");
    debugPrint("--------------------------------------------------");


    final location = json["location"];
    final statsJson = json["statistics"];

    // Debug için kalsın, veriyi gördük
    debugPrint("🔍 [PARSE-START] ID: ${json["id"]}");

    return UserModel(
      id: json["id"]?.toString() ?? "",
      phone: json["phone"]?.toString() ?? "",
      firstName: json["first_name"], // Logda "first_name"
      lastName: json["last_name"],   // Logda "last_name"
      fullName: json["full_name"],   // Logda "full_name"
      email: json["email"],
      birthDate: json["birth_date"]?.toString(), // 🎯 Logda: "birth_date"

      // 🔥 LOGA GÖRE GÜNCELLENEN KRİTİK ALANLAR:
      // phone_verified_at dolu gelirse true döner
      isEmailVerified: json["email_verified_at"] != null && json["email_verified_at"].toString().isNotEmpty,
      isPhoneVerified: json["phone_verified_at"] != null &&
          json["phone_verified_at"].toString().toLowerCase() != "null" &&
          json["phone_verified_at"].toString().trim().isNotEmpty,

      latitude: json["latitude"] != null ? double.tryParse(json["latitude"].toString()) : null,
      longitude: json["longitude"] != null ? double.tryParse(json["longitude"].toString()) : null,

      locationLat: location != null ? (location["lat"]?.toDouble()) : null,
      locationLng: location != null ? (location["lng"]?.toDouble()) : null,

      fcmToken: json["fcm_token"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      token: token ?? json["token"],
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