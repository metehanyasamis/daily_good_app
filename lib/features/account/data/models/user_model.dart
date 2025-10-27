import 'dart:convert';

class UserModel {
  final String id;
  final String phoneNumber;
  final String token;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? name;
  final String? surname;
  final String? email;
  final String? gender;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.token,
    required this.isPhoneVerified,
    required this.isEmailVerified,
    this.name,
    this.surname,
    this.email,
    this.gender,
  });

  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? token,
    bool? isPhoneVerified,
    bool? isEmailVerified,
    String? name,
    String? surname,
    String? email,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      token: token ?? this.token,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      gender: gender ?? this.gender,
    );
  }

  /// ✅ JSON’a dönüştür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'token': token,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'name': name,
      'surname': surname,
      'email': email,
      'gender': gender,
    };
  }

  /// ✅ JSON’dan model oluştur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      token: json['token'] ?? '',
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      isEmailVerified: json['isEmailVerified'] ?? false,
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      gender: json['gender'],
    );
  }

  /// (Opsiyonel) String serialize/deserialize için kolaylık
  String toRawJson() => jsonEncode(toJson());
  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(jsonDecode(str));
}
