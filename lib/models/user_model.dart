import 'package:flutter_firebase_auth_ui/constants.dart';

class UserModel {
  String uid;
  String name;
  String imageUrl;
  String phone;
  String email;
  String aboutMe;
  String fcmToken;
  String createdAt;
  bool isOnline;

  // constructor
  UserModel({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.phone,
    required this.email,
    required this.aboutMe,
    required this.fcmToken,
    required this.createdAt,
    required this.isOnline,
  });

  // factory from json
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json[Constants.uid] ?? '',
      name: json[Constants.name] ?? '',
      imageUrl: json[Constants.imageUrl] ?? '',
      phone: json[Constants.phone] ?? '',
      email: json[Constants.email] ?? '',
      aboutMe: json[Constants.aboutMe] ?? '',
      fcmToken: json[Constants.fcmToken] ?? '',
      createdAt: json[Constants.createdAt] ?? '',
      isOnline: json[Constants.isOnline] ?? false,
    );
  }

  // to json
  Map<String, dynamic> toJson() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.imageUrl: imageUrl,
      Constants.phone: phone,
      Constants.email: email,
      Constants.aboutMe: aboutMe,
      Constants.fcmToken: fcmToken,
      Constants.createdAt: createdAt,
      Constants.isOnline: isOnline,
    };
  }

  // copy with
  UserModel copyWith({
    String? uid,
    String? name,
    String? imageUrl,
    String? phone,
    String? email,
    String? aboutMe,
    String? fcmToken,
    String? createdAt,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      aboutMe: aboutMe ?? this.aboutMe,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  // initialize
  static UserModel initialModel({
    required String uid,
    String name = '',
    String imageUrl = '',
    String phone = '',
    String email = '',
  }) {
    return UserModel(
      uid: uid,
      name: name,
      imageUrl: imageUrl,
      phone: phone,
      email: email,
      aboutMe: 'Hey there! I am using Firebase Auth App',
      fcmToken: '',
      createdAt: '',
      isOnline: false,
    );
  }
}
