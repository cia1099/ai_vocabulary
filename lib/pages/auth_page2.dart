part of 'auth_page.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.onLoginPressed,
    required this.onSignUpPressed,
    required this.safeArea,
  });

  final VoidCallback onSignUpPressed;
  final VoidCallback onLoginPressed;
  final double safeArea;

  @override
  Widget build(BuildContext context) {
    String email = '', password = '';
    final errorNotifier = ValueNotifier('');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: safeArea),
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
                    login(email, value, context, errorNotifier);
                    TextInput.finishAutofillContext();
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
                          child: ValueListenableBuilder(
                            valueListenable: errorNotifier,
                            builder:
                                (context, error, child) => Text(
                                  error,
                                  style: TextStyle(color: Colors.red),
                                ),
                          ),
                        ),
                        PlatformTextButton(
                          onPressed: () {},
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
                AuthButton(
                  onPressed: (_) {
                    login(email, password, context, errorNotifier);
                  },
                  brand: Method.custom,
                  text: "Login",
                  textColor: Colors.white,
                  backgroundColor: headerLoginColor,
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
                AuthMultiButtons(
                  onPressed: (method) {},
                  brands: [Method.google, Method.apple, Method.facebook],
                ),
                DetermineVisibility(
                  // scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      CallToActionText("Don't have an account?"),
                      CallToActionButton(
                        onPressed: onSignUpPressed,
                        text: 'Sign Up',
                        color: headerSignUpColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login(
    String email,
    String password,
    BuildContext context,
    ValueNotifier errorNotifier,
  ) async {
    errorNotifier.value = '';
    showPlatformDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DummyDialog(msg: ''),
    );
    debugPrint('email: $email, password: $password');
    final token = await loginByFirebase(email, password).onError((e, _) {
      errorNotifier.value = 'Login failed, please check your email or password';
      return null;
    });
    if (token != null) {
      try {
        final user = await loginFirebaseToken(token);
        // errorNotifier.value = "Successfully login";
      } catch (e) {
        errorNotifier.value = messageExceptions(e);
      }
    }
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
    required this.onLoginPressed,
    required this.onSignUpPressed,
    required this.safeArea,
  });

  final VoidCallback onLoginPressed;
  final VoidCallback onSignUpPressed;
  final double safeArea;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: safeArea),
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CallToActionText('Create an account'),
              ),
              TextInputBox(
                icon:
                    isCupertino(context)
                        ? CupertinoIcons.person_crop_square
                        : Icons.portrait,
                hintText: 'Name',
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.name,
              ),
              TextInputBox(
                icon: PlatformIcons(context).mail, //Icons.email,
                hintText: 'Email',
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
              ),
              TextInputBox(
                icon: PlatformIcons(context).padlockOutline,
                hintText: 'Password',
                obscureText: true,
              ),
              AuthButton(
                onPressed: (_) => onSignUpPressed(),
                brand: Method.custom,
                text: "Sign Up",
                textColor: Colors.white,
                backgroundColor: headerSignUpColor,
              ),
              DetermineVisibility(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Expanded(
                      flex: 3,
                      child: Center(
                        child: CallToActionText('Already have an account?'),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: CallToActionButton(
                        text: 'Sign in',
                        onPressed: onLoginPressed,
                        color: headerLoginColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
        builder:
            (context, setState) => TextFormField(
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
                  borderSide: const BorderSide(
                    color: Colors.white54,
                    width: 2.0,
                  ),
                ),
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white70),
                suffixIcon:
                    obscureText
                        ? IconButton(
                          onPressed:
                              () => setState(() {
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
    required this.onPressed,
    required this.text,
    required this.color,
  });

  final VoidCallback onPressed;
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
