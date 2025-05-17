import 'dart:async';

import 'package:ai_vocabulary/model/user.dart';
import 'package:authentication_buttons/authentication_buttons.dart'
    show AuthenticationMethod;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../api/dict_api.dart';
import '../utils/handle_except.dart';
import 'authorization.dart';

abstract interface class UserSignIn {
  void successfullyLogin(SignInUser user);
}

mixin FirebaseAuthMixin<T extends StatefulWidget> on State<T>
    implements UserSignIn {
  var _cacheUser = false;
  bool get cacheUser => _cacheUser;

  @override
  initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      user
          .getIdToken(true)
          .then(
            (token) async {
              try {
                final singInUser = await loginFirebaseToken(token!);
                _cacheUser = true;
                successfullyLogin(singInUser);
              } catch (_) {
                signOutFirebase();
              }
            },
            onError: (_) {
              initAuthPage(false);
              return signOutFirebase();
            },
          )
          .whenComplete(() => initAuthPage(true));
    } else {
      initAuthPage(false);
    }
  }

  void initAuthPage(bool hasUser) {}

  Future<String?> login(String email, String password) async {
    String? errorMessage;
    final res = await loginByFirebase(email, password);
    if (res.status == 200) {
      await loginFirebaseToken(res.content).then(
        successfullyLogin,
        onError: (e) => errorMessage = messageExceptions(e),
      );
    } else {
      errorMessage = res.content;
    }
    return errorMessage;
  }

  Future<String?> register(
    String email,
    String password, [
    String? name,
  ]) async {
    String? errorMessage;
    final res = await signUpInFirebase(email, password);
    if (res.status == 200) {
      errorMessage = await registerFirebaseToken(
        token: res.content,
        name: name,
      ).then((_) => null, onError: (e) => messageExceptions(e));
    } else {
      errorMessage = res.content;
    }
    return errorMessage;
  }

  Future<String?> resetPassword(String email) =>
      resetFirebasePassword(email).then((_) => null, onError: (e) => e.message);

  Future<String?> socialLogin(AuthenticationMethod method) async {
    String? errorMessage;
    final res = await switch (method) {
      AuthenticationMethod.google => signInWithGoogle(),
      AuthenticationMethod.facebook => signInWithFacebook(),
      _ => Future.value(
        ApiResponse(status: 203, content: "Unsupported social login method"),
      ),
    };
    if (res.status == 200) {
      await loginFirebaseToken(res.content).then(
        successfullyLogin,
        onError: (e) => errorMessage = messageExceptions(e),
      );
    } else {
      errorMessage = res.content;
    }
    return errorMessage;
  }
}
