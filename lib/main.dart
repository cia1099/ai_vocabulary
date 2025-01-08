import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/pages/favorite_words_page.dart';
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
  static final brightSwitcher = ValueNotifier(false);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AppRoute {
  var appTheme = ThemeData();

  @override
  void initState() {
    super.initState();
    MyDB();
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
                      .apply(color: appTheme.colorScheme.primary),
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
          onGenerateRoute: generateRoute,
          initialRoute: AppRoute.home,
          // home: const FavoriteWordsPage(),
          // home: Builder(builder: (context) {
          //   return PlatformScaffold(
          //     body: Center(
          //       child: CupertinoButton.filled(
          //           onPressed: () => showPlatformModalSheet(
          //                 context: context,
          //                 builder: (context) =>
          //                     const ManageCollectionSheet(wordID: 830),
          //               ),
          //           child: const Text('Go Route!')),
          //     ),
          //   );
          // }),
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
    ColorScheme.fromImageProvider(
            provider: NetworkImage(url), brightness: appTheme.brightness)
        .then((newScheme) {
      setState(() {
        appTheme = ThemeData.from(colorScheme: newScheme);
      });
    });
  }
}
