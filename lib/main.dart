import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app_settings.dart';
import 'firebase_options.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).whenComplete(() {
    runApp(AppSettings(notifier: MySettings(), child: const MyApp()));
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var appTheme = ThemeData(
    appBarTheme: const AppBarTheme(actionsIconTheme: IconThemeData(size: 32)),
    // brightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    initPurchases(Theme.of(context).platform);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSettings.of(context).addListener(handleSettings);
      // ..loadSetting();
    });
  }

  @override
  void dispose() {
    AppSettings.of(context).removeListener(handleSettings);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      settings: PlatformSettingsData(iosUsesMaterialWidgets: true),
      builder: (context) => PlatformTheme(
        materialLightTheme: appTheme,
        builder: (context) => PlatformApp(
          debugShowCheckedModeBanner: false,
          cupertino: (context, platform) => CupertinoAppData(
            theme: MaterialBasedCupertinoThemeData(
              materialTheme: Theme.of(context).copyWith(
                cupertinoOverrideTheme: CupertinoThemeData(
                  applyThemeToAll: true,
                  textTheme: CupertinoTextThemeData(
                    navActionTextStyle: CupertinoTheme.of(context)
                        .textTheme
                        .actionTextStyle
                        .apply(color: appTheme.colorScheme.onPrimaryContainer),
                  ),
                  // primaryColor: appTheme.colorScheme.primary,
                  barBackgroundColor: appTheme.colorScheme.primaryContainer,
                ),
              ),
            ),
          ),
          title: 'AI Vocabulary App',
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: (settings) => AppRoute(
            settings: settings,
            barrierColor: (kCupertinoModalBarrierColor as CupertinoDynamicColor)
                .resolveFrom(context),
          ),
          // initialRoute: AppRoute.login,
          home: AuthPage(),
          // home: Builder(
          //   builder: (context) {
          //     return PlatformScaffold(
          //       body: Center(
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             // PunchCalendar(),
          //             CupertinoButton.filled(
          //               onPressed: () {},
          //               // appearAward(context, 'apple'),
          //               // showPlatformModalSheet(
          //               //   context: context,
          //               //   builder:
          //               //       (context) =>
          //               //           const ManageCollectionSheet(
          //               //             wordID: 830,
          //               //           ),
          //               //   material: MaterialModalSheetData(
          //               //     backgroundColor: Colors.transparent,
          //               //     scrollControlDisabledMaxHeightRatio: 1,
          //               //     isDismissible: false,
          //               //   ),
          //               // ),
          //               child: Text('Go Route!'),
          //             ),
          //           ],
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ),
      ),
    );
  }

  void handleBrightnessChange(bool useDarkMode) {
    final brightness = useDarkMode ? Brightness.dark : Brightness.light;
    setState(() {
      appTheme = ThemeData(
        appBarTheme: appTheme.appBarTheme,
        colorScheme: ColorScheme.fromSeed(
          seedColor: appTheme.primaryColor,
          brightness: brightness,
        ),
      );
      // ThemeData(
      //     colorScheme:
      //         appTheme.colorScheme.copyWith(brightness: brightness),
      //     brightness: brightness);
    });
  }

  void handleSettings() async {
    final mySettings = AppSettings.of(context);
    if (mySettings.brightness != appTheme.brightness) {
      return handleBrightnessChange(mySettings.brightness == Brightness.dark);
    }
    final index = mySettings.colorIndex;
    var colorScheme = appTheme.colorScheme;
    if (index < ColorSeed.values.length) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: ColorSeed.values[index].color,
        brightness: mySettings.brightness,
      );
    } else if (index - ColorSeed.values.length <
        ColorImageProvider.values.length) {
      final url =
          ColorImageProvider.values[index - ColorSeed.values.length].url;
      colorScheme = await ColorScheme.fromImageProvider(
        provider: NetworkImage(url),
        brightness: mySettings.brightness,
      );
    }
    if (colorScheme == appTheme.colorScheme) {
      // print('without stateState');
      return;
    }
    setState(() {
      appTheme = ThemeData(
        appBarTheme: appTheme.appBarTheme,
        colorScheme: colorScheme,
      );
    });
  }

  Future<void> initPurchases(TargetPlatform platform) async {
    if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);

    final revenueCatKey = switch (platform) {
      TargetPlatform.iOS => "appl_BhfSwLRtzObwxuwlHUNddWezqtr",
      TargetPlatform.android => "goog_AgjIXnZbhaZFktUJAWLuQcmNCaQ",
      _ => "",
    };

    final configuration = PurchasesConfiguration(revenueCatKey);
    await Purchases.configure(configuration);
  }
}
