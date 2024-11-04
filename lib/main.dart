import 'package:ai_vocabulary/pages/cloze_page.dart';
import 'package:ai_vocabulary/pages/entry_page.dart';
import 'package:ai_vocabulary/pages/home_page.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';
import 'package:ai_vocabulary/provider/word_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        builder: (context) => PlatformApp(
          title: 'AI Vocabulary App',
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
          ],
          onGenerateRoute: generateRoute,
          initialRoute: AppRoute.home,
        ),
      ),
    );
  }
}

extension AppRoute on _MyAppState {
  static const home = '/';
  static const entry = '/entry';
  static const entryVocabulary = '/entry/vocabulary';
  static const cloze = '/entry/cloze';

  Route generateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name!);
    final path = uri?.path;
    final currentWord = WordProvider.instance.currentWord;
    return platformPageRoute(
        context: context,
        builder: (context) => FlutterWebFrame(
              builder: (context) {
                switch (path) {
                  case AppRoute.entry:
                    return const EntryPage();
                  case AppRoute.cloze:
                    if (currentWord == null) return const HomePage();
                    return ClozePage(word: currentWord);
                  case AppRoute.entryVocabulary:
                    if (currentWord == null) return const HomePage();
                    return VocabularyPage(
                        word: currentWord,
                        nextTap: () => WordProvider.instance.nextWord());
                  default:
                    return const HomePage();
                }
              },
              maximumSize: const Size(300, 812.0), // Maximum size
              enabled: kIsWeb,
              backgroundColor: Colors.grey,
            ),
        settings: RouteSettings(name: currentWord != null ? path : '/'));
  }
}
