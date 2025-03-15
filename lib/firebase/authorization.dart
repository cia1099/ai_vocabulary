import 'package:firebase_auth/firebase_auth.dart';

Future<String?> loginByFirebase(String email, String password) {
  return FirebaseAuth.instance.signOut().then(
    (_) => FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((credential) => credential.user?.getIdToken()),
  );
}

Future<String?> signUpInFirebase(String email, String password, String name) {
  return FirebaseAuth.instance
      .createUserWithEmailAndPassword(email: email, password: password)
      .then((credential) {
        // FirebaseAuth.instance.sendSignInLinkToEmail(email: email, actionCodeSettings: ActionCodeSettings(url: url))
        return credential.user?.getIdToken();
      });
}

void resetFirebasePassword(String email) {
  FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}
