import 'package:ai_vocabulary/model/user.dart';
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
  @override
  initState() {
    super.initState();
    if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
      FirebaseAuth.instance.currentUser?.getIdToken(true).then((token) async {
        if (token == null) return;
        loginFirebaseToken(token).then(successfullyLogin);
      });
    }
  }

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
}
