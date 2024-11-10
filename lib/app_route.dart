import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

import 'package:ai_vocabulary/pages/cloze_page.dart';
import 'package:ai_vocabulary/pages/entry_page.dart';
import 'package:ai_vocabulary/pages/home_page.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';

import 'provider/word_provider.dart';

mixin AppRoute<T extends StatefulWidget> on State<T> {
  static const home = '/';
  static const entry = '/entry';
  static const entryVocabulary = '/entry/vocabulary';
  static const cloze = '/entry/cloze';

  Route generateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name!);
    var path = uri?.path;
    final currentWord = WordProvider.instance.currentWord;
    if (currentWord == null) path = AppRoute.home;
    return platformPageRoute(
        context: context,
        builder: (context) => FlutterWebFrame(
              builder: (context) {
                switch (path) {
                  case AppRoute.entry:
                    return const EntryPage();
                  case AppRoute.cloze:
                    // if (currentWord == null) return const EntryPage();
                    return ClozePage(word: currentWord!);
                  case AppRoute.entryVocabulary:
                    // if (currentWord == null) return const EntryPage();
                    return VocabularyPage(
                        word: currentWord!,
                        nextTap: () => WordProvider.instance.nextStudyWord());
                  default:
                    return const HomePage();
                }
              },
              maximumSize: const Size(300, 812.0), // Maximum size
              enabled: kIsWeb,
              backgroundColor: CupertinoColors.systemGrey,
            ),
        settings: RouteSettings(name: path));
  }
}
