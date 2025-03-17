import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

Future<ApiResponse> loginByFirebase(String email, String password) {
  return FirebaseAuth.instance.signOut().then(
    (_) => FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
          (credential) async {
            if (!(credential.user?.emailVerified ?? false)) {
              return ApiResponse(status: 203, content: "Email not verified");
            }
            final token = await credential.user?.getIdToken();
            return ApiResponse(
              status: token == null ? 404 : 200,
              content: token ?? 'User not found',
            );
          },
          onError: (e) {
            if (e is FirebaseAuthException) {
              final message = switch (e.code) {
                'invalid-credential' =>
                  'Login failed, please check your email or password',
                _ => e.message,
              };
              return ApiResponse(
                status: 401,
                content: message ?? 'Firebase exception',
              );
            } else {
              return ApiResponse(status: 501, content: messageExceptions(e));
            }
          },
        ),
  );
}

Future<ApiResponse> signUpInFirebase(String email, String password) {
  return FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password)
      .then(
        (credential) async {
          // FirebaseAuth.instance.sendSignInLinkToEmail(email: email, actionCodeSettings: ActionCodeSettings(url: url))
          await credential.user?.sendEmailVerification();
          final token = await credential.user?.getIdToken();
          return ApiResponse(
            status: token == null ? 404 : 200,
            content: token ?? 'User not found',
          );
        },
        onError: (e) {
          return ApiResponse(
            status: 501,
            content: e.message ?? 'Firebase exception',
          );
        },
      );
}

Future<void> resetFirebasePassword(
  String email, [
  ActionCodeSettings? actionCodeSettings,
]) {
  return FirebaseAuth.instance.sendPasswordResetEmail(
    email: email,
    actionCodeSettings: actionCodeSettings,
  );
}

Future<ApiResponse> signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
  return FirebaseAuth.instance.signInWithCredential(credential).then(
    (credential) async {
      final token = await credential.user?.getIdToken();
      return ApiResponse(
        status: token == null ? 404 : 200,
        content: token ?? 'User not found',
      );
    },
    onError:
        (e) => ApiResponse(
          status: 501,
          content: e.message ?? 'Firebase exception',
        ),
  );
}

Future<ApiResponse> signInWithFacebook() async {
  // Trigger the sign-in flow
  final LoginResult loginResult = await FacebookAuth.instance.login();
  // Create a credential from the access token
  if (loginResult.accessToken?.tokenString != null) {
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
    return FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential)
        .then(
          (credential) async {
            final token = await credential.user?.getIdToken();
            return ApiResponse(
              status: token == null ? 404 : 200,
              content: token ?? 'User not found',
            );
          },
          onError:
              (e) => ApiResponse(
                status: 501,
                content: e.message ?? 'Firebase exception',
              ),
        );
  }
  return ApiResponse(status: 501, content: "Failed login Facebook");
}
