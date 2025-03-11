import 'dart:convert' show JsonEncoder;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Text('There is no User');
                }
                final user = snapshot.data;
                return FutureBuilder(
                  future: user!.getIdTokenResult(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const CircularProgressIndicator.adaptive();
                    }
                    final encoder = JsonEncoder.withIndent(' ' * 4);
                    return Text(encoder.convert(snapshot.data!.claims));
                  },
                );
              },
            ),
            SizedBox(height: 100),
            PlatformElevatedButton(
              onPressed: () => signInWithEmailAndPassword(),
              child: Text('Sing In'),
            ),
            SizedBox(height: 10),
            PlatformElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('Sing Out'),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserCredential> signInWithEmailAndPassword([
    String email = "test123@test.com",
    String password = "sonic747",
  ]) async {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
          (credential) {
            final user = credential.user;
            user?.getIdToken().then((token) {
              print("token = $token");
            });
            return credential;
          },
          onError: (err) {
            print(err);
          },
        );
  }
}
