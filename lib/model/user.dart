import 'dart:convert';

class SignInUser {
  String uid;
  String email;
  String accessToken;
  String name;

  SignInUser({
    required this.uid,
    required this.email,
    required this.accessToken,
    required this.name,
  });

  factory SignInUser.fromRawJson(String str) =>
      SignInUser.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SignInUser.fromJson(Map<String, dynamic> json) => SignInUser(
    uid: json["uid"],
    email: json["email"],
    accessToken: json["access_token"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "access_token": accessToken,
    "name": name,
  };
}
