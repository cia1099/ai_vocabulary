import 'package:ai_vocabulary/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/user.dart';
import 'package:flutter_test/flutter_test.dart';

Future<SignInUser> testerWithFirebase({
  String email = "test123@test.com",
  String password = "sonic747",
}) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final res = await FirebaseAuth.instance
      .signInWithEmailAndPassword(email: email, password: password)
      .then((credential) async {
        final token = await credential.user?.getIdToken();
        return ApiResponse(
          status: token == null ? 404 : 200,
          content: token ?? 'User not found',
        );
      }, onError: (e) => ApiException(e.message));
  if (res.status == 200) {
    final token = res.content;
    return loginFirebaseToken(token);
  } else {
    throw ApiException(res.content);
  }
}
