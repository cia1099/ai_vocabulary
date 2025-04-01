import 'dart:convert';

class SignInUser {
  final String uid;
  final String email;
  final String accessToken;
  final String name;
  final String role;

  SignInUser({
    required this.uid,
    required this.email,
    required this.accessToken,
    required this.name,
    required this.role,
  });

  factory SignInUser.fromRawJson(String str) =>
      SignInUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SignInUser.fromJson(Map<String, dynamic> json) => SignInUser(
    uid: json["uid"],
    email: json["email"],
    accessToken: json["access_token"],
    name: json["name"],
    role: json["role"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "access_token": accessToken,
    "name": name,
    "role": role,
  };
}
