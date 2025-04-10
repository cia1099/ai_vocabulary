import 'dart:async';

import 'package:ai_vocabulary/model/user.dart';

class UserProvider {
  SignInUser? _user;
  final _userState = StreamController<SignInUser?>();
  late final _provider = _userState.stream.asBroadcastStream();
  static UserProvider? _instance;
  UserProvider._internal();
  static UserProvider get instance => _instance ??= UserProvider._internal();
  factory UserProvider() => instance;

  SignInUser? get currentUser => _user;
  set currentUser(SignInUser? user) {
    print('Access Token: ${user?.accessToken}');
    _user = user;
    _userState.add(_user);
  }

  Stream<SignInUser?> userStateChanges() async* {
    yield _user;
    yield* _provider;
  }
}
