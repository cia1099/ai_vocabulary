import 'package:ai_vocabulary/pages/word_list_page.dart';
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
  static const reviewWords = '/entry/review';
  static const todayWords = '/today/words';
  static const chatRoom = '/chat/room';
  static const vocabulary = '/vocabulary';
  static const report = '/report';
  static const menuPopup = '/menu/popup';
  static const searchWords = '/search/words';

  Route generateRoute(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name!);
    var path = uri?.path;
    final currentWord = WordProvider.instance.currentWord;
    // if (currentWord == null) path = AppRoute.home;
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
                        nextTap: () {
                          if (WordProvider().shouldRemind()) {
                            Navigator.of(context)
                                .popAndPushNamed(AppRoute.reviewWords);
                          } else {
                            WordProvider().nextStudyWord();
                            Navigator.of(context)
                                .popUntil(ModalRoute.withName(AppRoute.entry));
                          }
                        });
                  case AppRoute.todayWords:
                    return WordListPage(words: WordProvider().subList());
                  case AppRoute.reviewWords:
                    final reviews = WordProvider().remindWords();
                    return WordListPage(
                        words: reviews,
                        nextTap: () {
                          WordProvider().nextStudyWord();
                          Navigator.of(context)
                              .popUntil(ModalRoute.withName(AppRoute.entry));
                        });
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

bool fromEntry(String? routeName) {
  return routeName != null && routeName.contains('entry');
}
