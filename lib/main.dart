import 'package:ai_vocabulary/app_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'app_settings.dart';
import 'pages/home_page.dart';
import 'theme.dart';

void main() {
  runApp(AppSettings(notifier: MySettings(), child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var appTheme = ThemeData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppSettings.of(context).addListener(handleSettings);
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
      settings: PlatformSettingsData(
        iosUsesMaterialWidgets: true,
      ),
      builder: (context) => PlatformTheme(
        materialLightTheme: appTheme,
        //TODO: apply global fontsize scale
        // .copyWith(textTheme: Theme.of(context).textTheme.apply(fontSizeFactor: 1.2)),
        builder: (context) => PlatformApp(
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
              )),
            ),
          ),
          title: 'AI Vocabulary App',
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: //generateRoute,
              (settings) => AppRoute(
            settings: settings,
            barrierColor: (kCupertinoModalBarrierColor as CupertinoDynamicColor)
                .resolveFrom(context),
          ),
          initialRoute: AppRoute.home,
          home: const HomePage(),
          // home: Builder(builder: (context) {
          //   return PlatformScaffold(
          //     body: Center(
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           const Calendar(),
          //           CupertinoButton.filled(
          //               onPressed: () => appearAward(context, 'apple'),
          //               // showPlatformModalSheet(
          //               //       context: context,
          //               //       builder: (context) =>
          //               //           const ManageCollectionSheet(wordID: 830),
          //               //     ),
          //               child: const Text('Go Route!')),
          //         ],
          //       ),
          //     ),
          //   );
          // }),
        ),
      ),
    );
  }

  void handleBrightnessChange(bool useDarkMode) {
    final brightness = useDarkMode ? Brightness.dark : Brightness.light;
    setState(() {
      appTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: appTheme.colorScheme.primary, brightness: brightness),
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
    final index = mySettings.color;
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
          provider: NetworkImage(url), brightness: mySettings.brightness);
    }
    if (colorScheme == appTheme.colorScheme) {
      // print('without stateState');
      return;
    }
    setState(() {
      appTheme = ThemeData.from(colorScheme: colorScheme);
    });
  }
}
