import 'dart:async';
import 'dart:math' show pi;
import 'dart:ui';

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/effects/transient.dart';
import 'package:ai_vocabulary/firebase/authorization.dart'
    show signInAnonymously;
import 'package:ai_vocabulary/firebase/firebase_auth_mixin.dart';
import 'package:ai_vocabulary/model/user.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/pages/home_page.dart';
import 'package:ai_vocabulary/provider/user_provider.dart';
import 'package:ai_vocabulary/widgets/pull_data_dialog.dart';
import 'package:auth_button_kit/auth_button_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

part 'auth_page2.dart';

enum AuthState { login, signup, home }

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // animation variables
  late final _controller = AnimationController(
    value: 0,
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..addStatusListener(_animationStatusListener);
  late final _sequenceAnimation = _createSequenceAnimation();

  // variables to control the transition effect to the home page
  double _expandingWidth = 0;
  double _expandingHeight = 0;
  double _expandingBorderRadius = 500;
  final containerKey = GlobalKey<ImplicitlyAnimatedWidgetState>();
  final loginFormKey = GlobalKey<FirebaseAuthMixin>();
  final loginFromState = StreamController<bool?>();

  // constant values for the login/registration panel
  static const double _panelWidth = 350;
  static const double _panelHeight = 500;
  static const double _headerHeight = 60;

  // variables controlling authentication state
  bool _isLogin = true;
  AuthState _authState = AuthState.login;

  @override
  void initState() {
    super.initState();
    listenerFunc(VoidCallback f) => (AnimationStatus status) {
      if (status != AnimationStatus.completed) return;
      f();
    };

    final forwardListener = listenerFunc(() => _controller.forward());
    final routeListener = listenerFunc(() => _routeTransition());
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        containerKey.currentState?.animation.removeStatusListener(
          forwardListener,
        );
        containerKey.currentState?.animation.addStatusListener(routeListener);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      containerKey.currentState?.animation.addStatusListener(forwardListener);
      Future.delayed(Durations.extralong4).whenComplete(() {
        final hasUser = loginFormKey.currentState?.hasUser ?? true;
        if (!hasUser) loginFromState.add(false);
      });
    });
  }

  void _animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.dismissed) {
      if (_authState == AuthState.home) {
        _setHomeState();
        return;
      }

      _controller.forward(from: 0);

      if (_authState == AuthState.login) {
        _setLoginState(true);
        return;
      }
      if (_authState == AuthState.signup) {
        _setLoginState(false);
      }
    }
  }

  void _setHomeState() {
    setState(() {
      _expandingHeight = MediaQuery.sizeOf(context).height;
      _expandingWidth = MediaQuery.sizeOf(context).width;
      _expandingBorderRadius = 0;
      // _routeTransition();
    });
  }

  void _setLoginState(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
    });
  }

  void _onPress(AuthState state) {
    _controller.reverse();
    _authState = state;
  }

  Future<void> _routeTransition() async {
    await AppSettings.of(context).loadSetting();
    if (mounted) {
      final _ = await showPlatformDialog<bool>(
        context: context,
        builder: (context) => PullDataDialog(),
        // StreamBuilder(
        //   stream: () async* {
        //     yield* Stream.periodic(
        //       Durations.extralong4,
        //       (index) => ++index,
        //     ).take(5);
        //     if (context.mounted) {
        //       Navigator.maybePop(context, true);
        //     }
        //   }(),
        //   builder: (context, snapshot) {
        //     final remain = 5 - (snapshot.data ?? 0);
        //     final msg = remain > 0 ? 'remain waiting...${remain}s' : 'Done';
        //     return DummyDialog(msg: msg);
        //   },
        // ),
        barrierDismissible: false,
      );
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, _, __) => HomePage(),
          transitionsBuilder:
              (_, animation, _, child) => CupertinoDialogTransition(
                animation: animation,
                scale: .9,
                child: child,
              ),
          settings: RouteSettings(name: AppRoute.home),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: DecoratedBox(
        decoration: backgroundAuthDecoration(),
        child: Stack(
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: const FlutterLogo(style: FlutterLogoStyle.markOnly),
            ),
            Align(
              alignment: FractionalOffset(
                .5,
                .265 + _panelHeight / MediaQuery.sizeOf(context).height,
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder:
                    (context, _) => PlatformTextButton(
                      onPressed:
                          _controller.isCompleted
                              ? () => signInAnonymously(
                                entryFunc: (user) {
                                  UserProvider().currentUser = user;
                                  _onPress(AuthState.home);
                                },
                                errorOccur:
                                    (msg) => showToast(
                                      context: context,
                                      alignment: Alignment(0, .85),
                                      stay: Durations.extralong4 * 2,
                                      child: Text(
                                        msg,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                        ),
                                      ),
                                    ),
                              )
                              : null,
                      child: Text(
                        "Visitor",
                        style:
                            _controller.isCompleted
                                ? TextStyle(color: Colors.white70)
                                : null,
                      ),
                    ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, body) {
                  return ClipRRect(
                    clipBehavior: Clip.antiAlias,
                    borderRadius: BorderRadius.circular(
                      _sequenceAnimation['borderRadius']!.value,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        height: _sequenceAnimation['height']?.value,
                        width: _sequenceAnimation['width']?.value,
                        color: Colors.grey.shade300.withValues(alpha: 0.1),
                        child: Stack(
                          children: <Widget>[
                            Center(child: body),
                            Header(
                              scale: _sequenceAnimation['scale']!.value,
                              height: _sequenceAnimation['headerHight']!.value,
                              isLogin: _isLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child:
                    _isLogin
                        ? LoginForm(
                          key: loginFormKey,
                          safeArea: _headerHeight,
                          onSignUpPressed: () {
                            _onPress(AuthState.signup);
                          },
                          onLogin: (hasUser) {
                            if (hasUser) {
                              _routeTransition();
                            } else {
                              _onPress(AuthState.home);
                            }
                          },
                        )
                        : SignUpForm(
                          safeArea: _headerHeight,
                          onLoginPressed: () {
                            _onPress(AuthState.login);
                          },
                        ),
              ),
            ),
            StreamBuilder(
              stream: loginFromState.stream,
              builder:
                  (context, snapshot) => ExpandingPageAnimation(
                    containerKey: containerKey,
                    width:
                        snapshot.hasData
                            ? _expandingWidth
                            : MediaQuery.sizeOf(context).width,
                    height:
                        snapshot.hasData
                            ? _expandingHeight
                            : MediaQuery.sizeOf(context).height,
                    borderRadius: snapshot.hasData ? _expandingBorderRadius : 0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_animationStatusListener);
    _controller.animateBack(0);
    _controller.dispose();
    super.dispose();
  }

  Map<String, Animation<double>> _createSequenceAnimation() {
    final sequenceAnimation = <String, Animation<double>>{};
    sequenceAnimation['scale'] = CurvedAnimation(
      parent: _controller,
      curve: Interval(.5, 1, curve: Curves.easeIn),
    );
    sequenceAnimation['width'] = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: _headerHeight),
        weight: .5,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _headerHeight, end: _panelWidth),
        weight: .5,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, .5, curve: Curves.ease),
      ),
    );
    sequenceAnimation['height'] = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: _headerHeight,
        ).chain(CurveTween(curve: Curves.ease)),
        weight: .25,
      ),
      TweenSequenceItem(
        tween: ConstantTween(_headerHeight),
        weight: 1 - .25 - 5 / 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: _headerHeight, end: _panelHeight),
        weight: 5 / 12,
      ),
    ]).animate(_controller);
    sequenceAnimation['headerHight'] = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: _headerHeight,
        ).chain(CurveTween(curve: Curves.ease)),
        weight: .25,
      ),
      TweenSequenceItem(tween: ConstantTween(_headerHeight), weight: .33),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: _headerHeight,
          end: (_panelHeight - _headerHeight) / 2 + _headerHeight,
        ),
        weight: .21,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: (_panelHeight - _headerHeight) / 2 + _headerHeight,
          end: _headerHeight,
        ).chain(CurveTween(curve: Curves.ease)),
        weight: .21,
      ),
    ]).animate(_controller);
    sequenceAnimation['borderRadius'] = Tween<double>(
      begin: 0,
      end: kRadialReactionRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, .5, curve: Curves.ease),
      ),
    );
    return sequenceAnimation;
  }
}

class Header extends StatelessWidget {
  const Header({
    super.key,
    required double scale,
    required double height,
    required bool isLogin,
  }) : _scale = scale,
       _height = height,
       _isLogin = isLogin;

  final double _scale;
  final double _height;
  final bool _isLogin;

  @override
  Widget build(BuildContext context) {
    var headerText = 'Welcome';
    var color = headerLoginColor;
    if (!_isLogin) {
      headerText = "Let's get started";
      color = headerSignUpColor;
    }
    return Container(
      width: double.infinity,
      height: _height,
      color: color,
      child: Center(
        child: Transform.scale(
          scale: _scale,
          child: Text(
            headerText,
            overflow: TextOverflow.fade,
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ExpandingPageAnimation extends StatelessWidget {
  const ExpandingPageAnimation({
    super.key,
    required double width,
    required double height,
    required double borderRadius,
    required this.containerKey,
  }) : _width = width,
       _height = height,
       _borderRadius = borderRadius;

  final double _width;
  final double _height;
  final double _borderRadius;
  final GlobalKey<ImplicitlyAnimatedWidgetState> containerKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        key: containerKey,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius),
          gradient: LinearGradient(
            transform: GradientRotation(-pi / 4),
            stops: const [0.1, 0.5, 0.7, 0.9],
            colors: [
              homePageBackgroundColor[800]!,
              homePageBackgroundColor[700]!,
              homePageBackgroundColor[600]!,
              homePageBackgroundColor[400]!,
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration backgroundAuthDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      transform: GradientRotation(-pi / 4),
      stops: const [0.1, 0.5, 0.9],
      colors: [
        authPageBackgroundColor[700]!,
        authPageBackgroundColor[600]!,
        authPageBackgroundColor[400]!,
      ],
    ),
  );
}

const Color headerLoginColor = Color(0xff003153); //Color(0xFFAF2443);
const Color headerSignUpColor = Color(0xff8f4b28); //Color(0xFFD6A000);

const MaterialColor authPageBackgroundColor = Colors.blueGrey;
const MaterialColor homePageBackgroundColor = Colors.indigo;
