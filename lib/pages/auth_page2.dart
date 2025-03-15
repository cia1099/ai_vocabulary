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
                ),
                TextInputBox(
                  icon: PlatformIcons(context).padlockOutline,
                  hintText: 'Password',
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.visiblePassword,
                  autofillHints: [AutofillHints.password],
                  onFieldSubmitted: (value) {
                    TextInput.finishAutofillContext();
                  },
                  obscureText: true,
                ),
                PlatformElevatedButton(
                  onPressed: onLoginPressed,
                  color: headerLoginColor,
                  child: Text('Login', style: TextStyle(color: Colors.white)),
                ),
                DetermineVisibility(
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.white54, endIndent: 8),
                      ),
                      Text('or', style: TextStyle(color: Colors.white54)),
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
                    platform(context).index >> 1 & 1 > 0
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
              PlatformElevatedButton(
                onPressed: onSignUpPressed,
                color: headerSignUpColor,
                child: Text('Sign Up', style: TextStyle(color: Colors.white)),
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
    this.textCapitalization = TextCapitalization.none,
  });

  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final void Function(String value)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: TextFormField(
        obscureText: obscureText,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        onFieldSubmitted: onFieldSubmitted,
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
