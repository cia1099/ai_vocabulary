part of 'setting_tab.dart';

extension Methods on SettingTab {
  void deleteAccount(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showPlatformDialog<bool?>(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete this account?'),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDefaultAction: true),
          ),
          PlatformDialogAction(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
            material: (_, __) => MaterialDialogActionData(
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            ),
            cupertino: (_, __) =>
                CupertinoDialogActionData(isDestructiveAction: true),
          ),
        ],
      ),
    ).then((isDelete) {
      if (isDelete != true) return;
      signOutFirebase()
          .then((_) => deleteFirebaseAccount())
          .whenComplete(() => context.mounted && signOut(context));
    });
  }

  bool signOut(BuildContext context) {
    UserProvider().currentUser = null;
    AppSettings.of(context).resetCacheOrSignOut(signOut: true);
    //Never call log out https://www.revenuecat.com/docs/customers/identifying-customers#logging-out
    Navigator.pushReplacementNamed(context, AppRoute.login);
    return true;
  }

  void shareApp() {
    //     const text = """
    // Boost your English with smart, AI-powered vocabulary learning. Tailored quizzes, personalized review, and real-time feedback — right in your pocket.
    // Download and try now!
    // """;
    SharePlus.instance.share(
      ShareParams(
        // text: text,
        subject: "AI Vocabulary",
        uri: Uri.https("ai-vocabulary.com"),
      ),
    );
  }

  void restorePurchase(BuildContext context) async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final info = customerInfo.entitlements.active.values.firstOrNull?.toJson()
        ?..addAll({"gas": 200.0});
      if (info == null) throw HttpException("No transaction found");
      final user = await updateSubscript(info);
      UserProvider().currentUser = user;
    } catch (e) {
      if (context.mounted) {
        showToast(context: context, child: Text(messageExceptions(e)));
      }
    }
  }

  void requestReview() async {
    await InAppReview.instance.openStoreListing(appStoreId: '6747282773');
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.sizeOf(context).width / 32;
    return Container(
      alignment: Alignment(0, 0),
      // color: Colors.green,
      // height: 100, // minus SafeAre remains 100
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: StreamBuilder(
        stream: UserProvider().userStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator.adaptive();
          }
          final user = snapshot.data!;
          return InkWell(
            child: Row(
              spacing: hPadding,
              children: [
                CircleAvatar(
                  minRadius: 0,
                  maxRadius: 50,
                  foregroundImage: user.photoURL == null
                      ? null
                      : NetworkImage(user.photoURL!),
                  child: FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(CupertinoIcons.person_crop_circle),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? "Anonymous",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    Wrap(
                      children: [
                        LimitedBox(
                          maxWidth: 100,
                          child: Text(
                            "ID: ${user.uid}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: user.uid));
                          },
                          child: Transform(
                            transform: Matrix4.rotationX(pi),
                            alignment: Alignment(0, 0),
                            child: Icon(
                              CupertinoIcons.square_on_square,
                              size: textTheme.bodyMedium?.fontSize?.scale(
                                textTheme.bodyMedium?.height,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    PlatformTextButton(
                      onPressed: pressIdentity(context, user.role),
                      padding: EdgeInsets.zero,
                      child: Text(user.role.capitalize()),
                      material: (_, __) => MaterialTextButtonData(
                        style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(child: SizedBox()),
                Icon(
                  CupertinoIcons.right_chevron,
                  size: CupertinoTheme.of(
                    context,
                  ).textTheme.textStyle.fontSize?.scale(1.5),
                  color: CupertinoColors.systemGrey2.resolveFrom(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AccentSelector extends StatefulWidget {
  const AccentSelector({super.key});

  @override
  State<AccentSelector> createState() => _AccentSelectorState();
}

class _AccentSelectorState extends State<AccentSelector> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        for (final accent in Accent.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio.adaptive(
                value: accent,
                activeColor: Theme.of(context).colorScheme.primary,
                groupValue: AppSettings.of(context).accent,
                onChanged: (accent) => setState(() {
                  AppSettings.of(context).accent = accent!;
                }),
              ),
              Text(accent.flag, textScaler: TextScaler.linear(2)),
            ],
          ),
      ],
    );
  }
}

VoidCallback? pressIdentity(BuildContext context, [String? role]) {
  return switch (role) {
    "member" => () => Navigator.push(
      context,
      platformPageRoute(
        context: context,
        fullscreenDialog: true,
        builder: (context) => PaymentPage(),
      ),
    ),
    "guest" => () => showToast(
      context: context,
      alignment: Alignment(0, -.675),
      child: Text("You have to register first"),
    ),
    null => null,
    _ => () {},
  };
}
