part of 'auth_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    this.onLogin,
    this.onSignUpPressed,
    required this.initAuthPage,
    required this.safeArea,
  });

  final VoidCallback? onSignUpPressed;
  final Function(bool hasUser)? onLogin;
  final Function(bool hasUser) initAuthPage;
  final double safeArea;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> with FirebaseAuthMixin {
  String email = '', password = '';
  Future<String?> loginFuture = Future.value(null);
  AuthenticationMethod? loginMethod;

  @override
  void initAuthPage(bool hasUser) {
    super.initAuthPage(hasUser);
    widget.initAuthPage(hasUser);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: widget.safeArea),
          child: AutofillGroup(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: CallToActionText('Please sign in to continue'),
                ),
                TextInputBox(
                  icon: PlatformIcons(context).mail,
                  hintText: 'Email',
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email],
                  onChanged: (value) => email = value,
                ),
                TextInputBox(
                  icon: PlatformIcons(context).padlockOutline,
                  hintText: 'Password',
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  autofillHints: [AutofillHints.password],
                  onFieldSubmitted: (value) {
                    TextInput.finishAutofillContext();
                    signIn();
                  },
                  onChanged: (value) => password = value,
                  obscureText: true,
                ),
                DetermineVisibility(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: FutureBuilder(
                            future: loginFuture,
                            builder: (context, snapshot) {
                              final isWaiting =
                                  snapshot.connectionState ==
                                  ConnectionState.waiting;
                              return Offstage(
                                offstage: isWaiting || !snapshot.hasData,
                                child: Text(
                                  '${snapshot.data}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        PlatformTextButton(
                          onPressed: () async {
                            final inform =
                                await resetPassword(email) ??
                                "We've sent an email to\n$email.";
                            if (context.mounted && isMaterial(context)) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(inform)));
                            } else if (context.mounted) {
                              showToast(
                                context: context,
                                alignment: Alignment(0, .85),
                                child: Text(inform),
                              );
                            }
                          },
                          padding: EdgeInsets.zero,
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FutureBuilder(
                  future: loginFuture,
                  builder: (context, snapshot) {
                    final isWaiting =
                        snapshot.connectionState == ConnectionState.waiting;
                    return AuthButton(
                      onPressed: (_) => isWaiting ? null : signIn(),
                      brand: Method.custom,
                      text: "Login",
                      textColor: Colors.white,
                      backgroundColor: headerLoginColor,
                      showLoader: isWaiting && loginMethod == null,
                    );
                  },
                ),
                DetermineVisibility(
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.white54, endIndent: 8),
                      ),
                      Text('OR', style: TextStyle(color: Colors.white54)),
                      Expanded(
                        child: Divider(color: Colors.white54, indent: 8),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FutureBuilder(
                    future: loginFuture,
                    builder: (context, snapshot) {
                      final isWaiting =
                          snapshot.connectionState == ConnectionState.waiting;
                      // return AuthMultiButtons(
                      //   onPressed: (method) {
                      //     if (isWaiting) return;
                      //     setState(() {
                      //       loginMethod = method;
                      //       loginFuture = socialLogin(method);
                      //     });
                      //   },
                      //   brands: [Method.google, Method.apple, Method.facebook]
                      //     ..removeWhere(
                      //       (m) => isMaterial(context) && m == Method.apple,
                      //     ),
                      //   showLoader: isWaiting ? loginMethod : null,
                      // );
                      return Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children:
                            [
                                  AuthenticationMethod.google,
                                  if (isCupertino(context))
                                    AuthenticationMethod.apple,
                                  // AuthenticationMethod.facebook,
                                ]
                                .map(
                                  (method) => ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 60,
                                      minHeight: 60,
                                    ),
                                    child: AuthenticationButton(
                                      authenticationMethod: method,
                                      onPressed: () {
                                        if (isWaiting) return;
                                        setState(() {
                                          loginMethod = method;
                                          loginFuture = socialLogin(method);
                                        });
                                      },
                                      buttonSize: ButtonSize.small,
                                      showLoader:
                                          isWaiting && loginMethod == method,
                                    ),
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),
                ),
                DetermineVisibility(
                  // scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: double.infinity),
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        CallToActionText("Don't have an account?"),
                        CallToActionButton(
                          onPressed: widget.onSignUpPressed,
                          text: 'Sign Up',
                          color: headerSignUpColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn() {
    setState(() {
      loginFuture = login(email, password);
      loginMethod = null;
    });
  }

  @override
  void successfullyLogin([SignInUser? user]) {
    UserProvider().currentUser = user;
    widget.onLogin?.call(cacheUser);
    if (user != null && user.email.isNotEmpty) {
      Purchases.logIn(user.uid).then((login) async {
        final info = login.customerInfo.entitlements.active.values.firstOrNull;
        final customer = await updateSubscript(info?.toJson() ?? {});
        UserProvider().currentUser = customer;
      });
    }
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    this.onLoginPressed,
    this.onSignUpPressed,
    required this.safeArea,
  });

  final VoidCallback? onLoginPressed;
  final VoidCallback? onSignUpPressed;
  final double safeArea;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> with FirebaseAuthMixin {
  String email = '', password = '';
  String? name;
  Future<String?> registerFuture = Future.value(null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: widget.safeArea),
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CallToActionText('Create an account'),
              ),
              TextInputBox(
                icon: isCupertino(context)
                    ? CupertinoIcons.person_crop_square
                    : Icons.portrait,
                hintText: 'Name',
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                onChanged: (value) =>
                    value.isEmpty ? name = null : name = value,
                keyboardType: TextInputType.name,
              ),
              TextInputBox(
                icon: PlatformIcons(context).mail,
                hintText: 'Email',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
              ),
              TextInputBox(
                icon: PlatformIcons(context).padlockOutline,
                hintText: 'Password',
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) => password = value,
                onFieldSubmitted: (_) => signUp(),
                obscureText: true,
              ),
              FutureBuilder(
                future: registerFuture,
                builder: (context, snapshot) => Offstage(
                  offstage:
                      snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData,
                  child: Text(
                    "${snapshot.data}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
              FutureBuilder(
                future: registerFuture,
                builder: (context, snapshot) {
                  final isWaiting =
                      snapshot.connectionState == ConnectionState.waiting;
                  return AuthButton(
                    onPressed: (_) {
                      if (!isWaiting) signUp();
                      widget.onSignUpPressed?.call();
                    },
                    brand: Method.custom,
                    text: "Sign Up",
                    textColor: Colors.white,
                    backgroundColor: headerSignUpColor,
                    showLoader: isWaiting,
                  );
                },
              ),
              DetermineVisibility(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: double.infinity),
                  child: Wrap(
                    alignment: WrapAlignment.spaceEvenly,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      CallToActionText('Already have an account?'),
                      CallToActionButton(
                        text: 'Sign in',
                        onPressed: widget.onLoginPressed,
                        color: headerLoginColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signUp() {
    setState(() {
      registerFuture = register(email, password, name).then((error) {
        if (error == null && mounted) {
          showToast(
            context: context,
            alignment: Alignment(0, .85),
            child: Text("Please verify your email."),
          );
        }
        return error;
      });
    });
  }

  @override
  void successfullyLogin([SignInUser? user]) {}
}

class DetermineVisibility extends StatelessWidget {
  const DetermineVisibility({super.key, required this.child});

  final Widget child;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Visibility(
          visible: constraints.maxWidth > 250 && constraints.maxHeight > 50,
          child: child,
        );
      },
    );
  }
}

class TextInputBox extends StatelessWidget {
  const TextInputBox({
    super.key,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.textInputAction,
    this.keyboardType,
    this.autofillHints,
    this.onFieldSubmitted,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final void Function(String value)? onChanged;
  final void Function(String value)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    var isObscure = obscureText;
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: StatefulBuilder(
        builder: (context, setState) => TextFormField(
          obscureText: isObscure,
          textInputAction: textInputAction,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          textCapitalization: textCapitalization,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.white, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.white54, width: 2.0),
            ),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: obscureText
                ? IconButton(
                    onPressed: () => setState(() {
                      isObscure ^= true;
                    }),
                    icon: Icon(
                      isObscure
                          ? PlatformIcons(context).eyeSlash
                          : isCupertino(context)
                          ? CupertinoIcons.eye
                          : Icons.visibility_outlined,
                      color: Colors.white54,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class CallToActionButton extends StatelessWidget {
  const CallToActionButton({
    super.key,
    this.onPressed,
    required this.text,
    required this.color,
  });

  final VoidCallback? onPressed;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: TextStyle(color: color, fontSize: 16)),
    );
  }
}

class CallToActionText extends StatelessWidget {
  const CallToActionText(this.text, {super.key});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium!.copyWith(color: Colors.white70),
    );
  }
}
