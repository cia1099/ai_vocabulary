import 'package:ai_vocabulary/pages/home_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'app_route.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  static final colorSelectedIndex = ValueNotifier(0);
  static final brightSwitcher = ValueNotifier(true);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AppRoute {
  var appTheme = ThemeData();

  @override
  void initState() {
    super.initState();
    MyApp.colorSelectedIndex.addListener(colorListener);
    MyApp.brightSwitcher.addListener(brightListener);
  }

  @override
  void dispose() {
    WordProvider().dispose();
    // MyDB().dispose();
    MyApp.colorSelectedIndex.removeListener(colorListener);
    MyApp.brightSwitcher.removeListener(brightListener);
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
        builder: (context) => PlatformApp(
          cupertino: (context, platform) => CupertinoAppData(
            theme: MaterialBasedCupertinoThemeData(
              materialTheme: Theme.of(context).copyWith(
                  cupertinoOverrideTheme: CupertinoThemeData(
                applyThemeToAll: true,
                textTheme: const CupertinoTextThemeData(),
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
          onGenerateRoute: generateRoute,
          initialRoute: AppRoute.home,
          // home: const HomePage(),
        ),
      ),
    );
  }

  void colorListener() {
    final index = MyApp.colorSelectedIndex.value;
    if (index < ColorSeed.values.length) {
      handleColorSelect(index);
    } else if (index - ColorSeed.values.length <
        ColorImageProvider.values.length) {
      handleImageSelect(index - ColorSeed.values.length);
    }
  }

  void brightListener() {
    handleBrightnessChange(MyApp.brightSwitcher.value);
  }

  void handleBrightnessChange(bool useLightMode) {
    final brightness = useLightMode ? Brightness.light : Brightness.dark;
    setState(() {
      appTheme = ThemeData(
        typography: appTheme.typography,
        colorScheme: ColorScheme.fromSeed(
            seedColor: appTheme.colorScheme.primary, brightness: brightness),
      );
      // ThemeData(
      //     colorScheme: appTheme.colorScheme.copyWith(brightness: brightness),
      //     brightness: brightness);
    });
  }

  void handleColorSelect(int index) {
    setState(() {
      appTheme = ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
        seedColor: ColorSeed.values[index].color,
        brightness: appTheme.brightness,
      ));
    });
  }

  void handleImageSelect(int index) {
    final String url = ColorImageProvider.values[index].url;
    ColorScheme.fromImageProvider(provider: NetworkImage(url))
        .then((newScheme) {
      setState(() {
        appTheme = ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: newScheme.primary, brightness: appTheme.brightness),
        );
      });
    });
  }
}
