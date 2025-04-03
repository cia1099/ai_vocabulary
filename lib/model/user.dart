import 'dart:convert';

class SignInUser {
  final String uid;
  final String email;
  final String accessToken;
  final String role;
  final String? name;
  final String? photoURL;

  SignInUser({
    required this.uid,
    required this.email,
    required this.accessToken,
    required this.role,
    this.name,
    this.photoURL,
  });

  factory SignInUser.fromRawJson(String str) =>
      SignInUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SignInUser.fromJson(Map<String, dynamic> json) => SignInUser(
    uid: json["uid"],
    email: json["email"],
    accessToken: json["access_token"],
    role: json["role"],
    name: json["name"],
    photoURL: json["photoURL"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "access_token": accessToken,
    "role": role,
    "name": name,
    "photoURL": photoURL,
  };
}
