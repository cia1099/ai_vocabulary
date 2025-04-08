import 'package:ai_vocabulary/pages/auth_page.dart';
import 'package:ai_vocabulary/pages/punch_out_page.dart';
import 'package:ai_vocabulary/pages/quiz_shuttle.dart';
import 'package:ai_vocabulary/pages/word_list_page.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

import 'package:ai_vocabulary/pages/vocabulary_page.dart';

import 'app_settings.dart';
import 'database/my_db.dart';
import 'effects/transient.dart';
import 'pages/report_page.dart';

class AppRoute<T> extends PageRoute<T> {
  static const home = '/';
  static const login = '/login';
  static const entry = '/entry';
  static const entryVocabulary = '/entry/vocabulary';
  static const quiz = '/entry/quiz';
  static const reviewWords = '/entry/review';
  static const todayWords = '/today/words';
  static const chatRoom = '/chat/room';
  static const vocabulary = '/vocabulary';
  static const report = '/report';
  static const menuPopup = '/menu/popup';
  static const searchWords = '/search/words';

  @override
  final Color? barrierColor;

  AppRoute({this.barrierColor, super.settings});

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FlutterWebFrame(
      builder: (context) {
        final provider = AppSettings.of(context).wordProvider;
        final currentWord = provider?.currentWord;
        final uri = Uri.tryParse(settings.name!);
        var path = uri?.path;

        var msg = '';
        if (!validation(context)) {
          if (currentWord == null &&
              StudyRouters.asMap().values.contains(path)) {
            msg = "'$path' needs word, but word is null";
            path = "default";
          } else {
            msg = "'$path' not found";
          }
        }
        // print('overTarget = $overTarget');

        switch (path) {
          case AppRoute.quiz:
            return QuizShuttle(word: currentWord!);
          case AppRoute.vocabulary:
            return VocabularyPage(word: currentWord!);
          case AppRoute.entryVocabulary:
            return VocabularyPage(
              word: currentWord!,
              nextTap:
                  provider == null
                      ? null
                      : () {
                        final studyCount = MyDB().fetchStudyCounts();
                        final mySetting = AppSettings.of(context);
                        mySetting.studyState = mySetting.nextStatus(studyCount);
                        final reachTarget =
                            mySetting.studyState == StudyStatus.onTarget;
                        if (provider.shouldRemind(reachTarget)) {
                          Navigator.popAndPushNamed(
                            context,
                            AppRoute.reviewWords,
                            arguments: reachTarget,
                          );
                        } else {
                          provider.nextStudyWord();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
            );
          case AppRoute.todayWords:
          // return WordListPage(words: WordProvider().subList());
          case AppRoute.reviewWords:
            final reviews = provider?.remindWords() ?? [];
            return WordListPage(
              words: reviews,
              title: 'Review Words',
              nextTap:
                  provider == null
                      ? null
                      : () {
                        if (AppSettings.of(context).studyState ==
                            StudyStatus.onTarget) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            platformPageRoute(
                              context: context,
                              fullscreenDialog: true,
                              builder: (context) => const PunchOutPage(),
                            ),
                            (route) => route.isFirst,
                          );
                        } else {
                          provider.nextStudyWord();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      },
            );
          case AppRoute.report:
            return ReportPage(wordId: currentWord!.wordId);
          case AppRoute.login:
            return AuthPage();
          default:
            return DummyDialog(msg: msg);
        }
      },
      maximumSize: const Size(300, 812.0), // Maximum size
      enabled: kIsWeb,
      backgroundColor: CupertinoColors.systemGrey.resolveFrom(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (!validation(context)) {
      return CupertinoDialogTransition(animation: animation, child: child);
    }
    return SlideTransition(
      position: Tween(begin: Offset.fromDirection(0), end: Offset.zero).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.linearToEaseOut,
          reverseCurve: Curves.easeInToLinear,
        ),
      ),
      textDirection: Directionality.of(context),
      transformHitTests: false,
      child: child,
    );
  }

  bool validation(BuildContext context) {
    final currentWord = AppSettings.of(context).wordProvider?.currentWord;
    final uri = Uri.tryParse(settings.name ?? '');
    final path = uri?.path;
    // final isLogin = path == AppRouters.login.path;
    final validName = StudyRouters.asMap().values.contains(path);
    return currentWord != null && validName;
  }

  @override
  bool get maintainState => false;

  @override
  String? get barrierLabel => 'AppRouter holding';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get barrierDismissible => true;

  @override
  bool get opaque => false;
}

bool fromEntry(String? routeName) {
  return routeName != null && routeName.contains('entry');
}

enum StudyRouters implements Comparable<String> {
  // home('/'), // You shouldn't navigate to home, because it's root page
  entryVocabulary(AppRoute.entryVocabulary),
  // cloze(AppRoute.cloze),
  quiz(AppRoute.quiz),
  reviewWords(AppRoute.reviewWords),
  todayWords(AppRoute.todayWords),
  vocabulary(AppRoute.vocabulary),
  report(AppRoute.report);
  // chatRoom('/chat/room'),
  // menuPopup('/menu/popup'),
  // searchWords('/search/words');

  static Map<String, String> asMap() {
    return {for (final e in StudyRouters.values) e.name: e.path};
  }

  final String path;
  const StudyRouters(this.path);

  @override
  int compareTo(String other) => name.compareTo(other);
}
