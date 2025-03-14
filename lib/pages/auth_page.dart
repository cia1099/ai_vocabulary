import 'dart:math' show pi;
import 'dart:ui';

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
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // animation variables
  late AnimationController _controller;
  late Map<String, Animation<double>> _sequenceAnimation;

  // variables to control the transition effect to the home page
  double _expandingWidth = 0;
  double _expandingHeight = 0;
  double _expandingBorderRadius = 500;

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

    _controller = AnimationController(
      value: 1,
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener(_animationStatusListener);

    _initSequenceAnimation();
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_animationStatusListener);
    _controller.stop();
    _controller.dispose();
    super.dispose();
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
      _expandingHeight = MediaQuery.of(context).size.height;
      _expandingWidth = MediaQuery.of(context).size.width;
      _expandingBorderRadius = 0;
      _routeTransition();
    });
  }

  void _setLoginState(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
    });
  }

  void _initSequenceAnimation() {
    _sequenceAnimation = <String, Animation<double>>{};
    _sequenceAnimation['scale'] = CurvedAnimation(
      parent: _controller,
      curve: Interval(.5, 1, curve: Curves.easeIn),
    );
    _sequenceAnimation['width'] = TweenSequence<double>([
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
    _sequenceAnimation['height'] = TweenSequence<double>([
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
    _sequenceAnimation['headerHight'] = TweenSequence<double>([
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
    _sequenceAnimation['borderRadius'] = Tween<double>(
      begin: 0,
      end: kRadialReactionRadius,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0, .5, curve: Curves.ease),
      ),
    );
  }

  void _onPress(AuthState state) {
    _controller.reverse();
    _authState = state;
  }

  Future<void> _routeTransition() async {
    // return Future.delayed(const Duration(milliseconds: 500), () {
    //   Navigator.pushReplacement<dynamic, dynamic>(
    //     context,
    //     FadeRoute(const HomePage()),
    //   );
    // });
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
                          safeArea: _headerHeight,
                          onSignUpPressed: () {
                            _onPress(AuthState.signup);
                          },
                          onLoginPressed: () {
                            _onPress(AuthState.home);
                          },
                        )
                        : SignUpForm(
                          safeArea: _headerHeight,
                          onLoginPressed: () {
                            _onPress(AuthState.login);
                          },
                          onSignUpPressed: () {
                            _onPress(AuthState.home);
                          },
                        ),
              ),
            ),
            ExpandingPageAnimation(
              width: _expandingWidth,
              height: _expandingHeight,
              borderRadius: _expandingBorderRadius,
            ),
          ],
        ),
      ),
    );
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
  }) : _width = width,
       _height = height,
       _borderRadius = borderRadius;

  final double _width;
  final double _height;
  final double _borderRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
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
