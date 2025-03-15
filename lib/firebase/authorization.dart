import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<ApiResponse> loginByFirebase(String email, String password) {
  return FirebaseAuth.instance.signOut().then(
    (_) => FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
          (credential) async {
            final token = await credential.user?.getIdToken();
            return ApiResponse(
              status: token == null ? 404 : 200,
              content: token ?? 'User not found',
            );
          },
          onError: (err) {
            final e = err as FirebaseAuthException;
            final message = switch (e.code) {
              'invalid-credential' =>
                'Login failed, please check your email or password',
              _ => e.message,
            };
            return ApiResponse(
              status: 401,
              content: message ?? 'Firebase exception',
            );
          },
        ),
  );
}

Future<ApiResponse> signUpInFirebase(
  String email,
  String password,
  String name,
) {
  return FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password)
      .then(
        (credential) async {
          // FirebaseAuth.instance.sendSignInLinkToEmail(email: email, actionCodeSettings: ActionCodeSettings(url: url))
          final token = await credential.user?.getIdToken();
          return ApiResponse(
            status: token == null ? 404 : 200,
            content: token ?? 'User not found',
          );
        },
        onError: (err) {
          final e = err as FirebaseAuthException;
          return ApiResponse(
            status: 401,
            content: e.message ?? 'Firebase exception',
          );
        },
      );
}

void resetFirebasePassword(String email) {
  FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
