
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

  // Token sadece login sırasında gelir
  final String? token;

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
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final location = json["location"];

    return UserModel(
      id: json["id"] ?? "",
      phone: json["phone"] ?? "",
      firstName: json["first_name"],
      lastName: json["last_name"],
      fullName: json["full_name"],
      email: json["email"],
      birthDate: json["birth_date"],

      isEmailVerified: json["email_verified_at"] != null || (json["isEmailVerified"] == true),
      isPhoneVerified: json["phone_verified_at"] != null,

      latitude: json["latitude"] != null
          ? double.tryParse(json["latitude"].toString())
          : null,
      longitude: json["longitude"] != null
          ? double.tryParse(json["longitude"].toString())
          : null,

      locationLat: location != null ? (location["lat"]?.toDouble()) : null,
      locationLng: location != null ? (location["lng"]?.toDouble()) : null,

      fcmToken: json["fcm_token"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],

      // login sırasında token geçilir
      token: token,
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
    );
  }
}
