import 'package:ai_vocabulary/pages/word_list_page.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

import 'package:ai_vocabulary/pages/cloze_page.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';

import 'app_settings.dart';

class AppRoute<T> extends PageRoute<T> {
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

  @override
  final Color? barrierColor;

  AppRoute({this.barrierColor, super.settings});

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FlutterWebFrame(
      builder: (context) {
        final provider = AppSettings.of(context).wordProvider;
        final currentWord = provider?.currentWord;
        final uri = Uri.tryParse(settings.name!);
        var path = uri?.path;

        if (!validation(context)) {
          if (currentWord == null) {
            path = "'$path' needs word, but word is null";
          } else {
            path = "'$path' not found";
          }
        }

        switch (path) {
          case AppRoute.cloze:
            return ClozePage(word: currentWord!);
          case AppRoute.vocabulary:
            return VocabularyPage(word: currentWord!);
          case AppRoute.entryVocabulary:
            return VocabularyPage(
                word: currentWord!,
                nextTap: provider == null
                    ? null
                    : () {
                        if (provider.shouldRemind()) {
                          Navigator.popAndPushNamed(
                              context, AppRoute.reviewWords);
                        } else {
                          provider.nextStudyWord();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        }
                      });
          case AppRoute.todayWords:
          // return WordListPage(words: WordProvider().subList());
          case AppRoute.reviewWords:
            final reviews = provider?.remindWords() ?? [];
            return WordListPage(
              words: reviews,
              nextTap: provider == null
                  ? null
                  : () {
                      provider.nextStudyWord();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
            );
          default:
            return dummyDialog(context, path);
        }
      },
      maximumSize: const Size(300, 812.0), // Maximum size
      enabled: kIsWeb,
      backgroundColor: CupertinoColors.systemGrey.resolveFrom(context),
    );
  }

  Widget dummyDialog(BuildContext context, String? msg) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: .3333,
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
              decoration: BoxDecoration(
                color: kCupertinoSheetColor.resolveFrom(context),
                borderRadius: BorderRadius.circular(kRadialReactionRadius / 2),
              ),
              child: Stack(
                children: [
                  const Center(child: CircularProgressIndicator.adaptive()),
                  Align(
                    alignment: const Alignment(0, 1),
                    child: Text(
                      '$msg',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (!validation(context)) {
      return FadeTransition(
        opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOutBack),
        child: animation.status == AnimationStatus.reverse
            ? child
            : ScaleTransition(
                scale: Tween(begin: 1.3, end: 1.0).animate(animation),
                child: child),
      );
    }
    return SlideTransition(
      position: Tween(begin: Offset.fromDirection(0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: animation,
        curve: Curves.linearToEaseOut,
        reverseCurve: Curves.easeInToLinear,
      )),
      textDirection: Directionality.of(context),
      transformHitTests: false,
      child: child,
    );
  }

  bool validation(BuildContext context) {
    final currentWord = AppSettings.of(context).wordProvider?.currentWord;
    final uri = Uri.tryParse(settings.name ?? '');
    final path = uri?.path;
    final validName = AppRouters.asMap().values.contains(path);
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

enum AppRouters implements Comparable<String> {
  // home('/'), // You shouldn't navigate to home, because it's root page
  entry('/entry'),
  entryVocabulary('/entry/vocabulary'),
  cloze('/entry/cloze'),
  reviewWords('/entry/review'),
  todayWords('/today/words'),
  chatRoom('/chat/room'),
  vocabulary('/vocabulary'),
  report('/report'),
  menuPopup('/menu/popup'),
  searchWords('/search/words');

  static Map<String, String> asMap() {
    return {
      for (final e in AppRouters.values) e.name: e.path,
    };
  }

  final String path;
  const AppRouters(this.path);

  @override
  int compareTo(String other) => name.compareTo(other);
}
