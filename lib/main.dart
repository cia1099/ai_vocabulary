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

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AppRoute {
  var appTheme = ThemeData();

  @override
  void dispose() {
    WordProvider().dispose();
    // MyDB().dispose();
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
                materialTheme: Theme.of(context)),
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

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      appTheme = ThemeData(
          colorScheme: appTheme.colorScheme,
          brightness: useLightMode ? Brightness.light : Brightness.dark);
    });
  }

  void handleColorSelect(int index) {
    setState(() {
      appTheme = ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
              seedColor: ColorSeed.values[index].color,
              brightness: appTheme.brightness));
    });
  }

  void handleImageSelect(int index) {
    final String url = ColorImageProvider.values[index].url;
    ColorScheme.fromImageProvider(provider: NetworkImage(url))
        .then((newScheme) {
      setState(() {
        appTheme =
            ThemeData(colorScheme: newScheme, brightness: appTheme.brightness);
      });
    });
  }
}
