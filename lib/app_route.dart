import 'package:ai_vocabulary/pages/home_page.dart';
import 'package:ai_vocabulary/pages/word_list_page.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';

import 'package:ai_vocabulary/pages/cloze_page.dart';
import 'package:ai_vocabulary/pages/vocabulary_page.dart';

import 'app_settings.dart';
import 'provider/word_provider.dart';

// mixin AppRoute<T extends StatefulWidget> on State<T> {
//   static const home = '/';
//   static const entry = '/entry';
//   static const entryVocabulary = '/entry/vocabulary';
//   static const cloze = '/entry/cloze';
//   static const reviewWords = '/entry/review';
//   static const todayWords = '/today/words';
//   static const chatRoom = '/chat/room';
//   static const vocabulary = '/vocabulary';
//   static const report = '/report';
//   static const menuPopup = '/menu/popup';
//   static const searchWords = '/search/words';

//   Route generateRoute(RouteSettings settings) {
//     final uri = Uri.tryParse(settings.name!);
//     final path = uri?.path;
//     return platformPageRoute(
//         context: context,
//         builder: (context) => FlutterWebFrame(
//               builder: (context) {
//                 final provider = AppSettings.of(context).wordProvider;
//                 final currentWord = provider?.currentWord;
//                 switch (provider.runtimeType) {
//                   case ReviewProvider:
//                     print('review from route, word: ${currentWord?.word}');
//                   case RecommendProvider:
//                     print('recommend from route, word: ${currentWord?.word}');
//                   default:
//                     break;
//                 }
//                 switch (path) {
//                   // case AppRoute.entry:
//                   // return EntryPage();
//                   case AppRoute.cloze:
//                     // if (currentWord == null) return const EntryPage();
//                     return ClozePage(word: currentWord!);
//                   case AppRoute.entryVocabulary:
//                     // if (currentWord == null) return const EntryPage();
//                     return VocabularyPage(
//                         word: currentWord!,
//                         nextTap: () {
//                           // if (WordProvider().shouldRemind()) {
//                           //   Navigator.of(context)
//                           //       .popAndPushNamed(AppRoute.reviewWords);
//                           // } else {
//                           //   WordProvider().nextStudyWord();
//                           //   Navigator.of(context)
//                           //       .popUntil(ModalRoute.withName(AppRoute.entry));
//                           // }
//                         });
//                   case AppRoute.todayWords:
//                   // return WordListPage(words: WordProvider().subList());
//                   case AppRoute.reviewWords:
//                   // final reviews = WordProvider().remindWords();
//                   // return WordListPage(
//                   //     words: reviews,
//                   //     nextTap: () {
//                   //       WordProvider().nextStudyWord();
//                   //       Navigator.of(context)
//                   //           .popUntil(ModalRoute.withName(AppRoute.entry));
//                   //     });
//                   default:
//                     print('build from $provider');
//                     return const HomePage();
//                 }
//               },
//               maximumSize: const Size(300, 812.0), // Maximum size
//               enabled: kIsWeb,
//               backgroundColor: CupertinoColors.systemGrey.resolveFrom(context),
//             ),
//         settings: RouteSettings(name: path));
//   }
// }

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
        switch (provider.runtimeType) {
          case ReviewProvider:
            print('review from route, word: ${currentWord?.word}');
          case RecommendProvider:
            print('recommend from route, word: ${currentWord?.word}');
          default:
            break;
        }
        if (!Navigator.canPop(context)) return const HomePage();
        if (currentWord == null) {
          return Center(
            child: FractionallySizedBox(
              widthFactor: .3333,
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                    alignment: const Alignment(0, 0),
                    decoration: BoxDecoration(
                      color: kCupertinoSheetColor.resolveFrom(context),
                      borderRadius:
                          BorderRadius.circular(kRadialReactionRadius / 2),
                    ),
                    child: const CircularProgressIndicator.adaptive()),
              ),
            ),
          );
        }
        final uri = Uri.tryParse(settings.name!);
        final path = uri?.path;
        switch (path) {
          // case AppRoute.entry:
          // return EntryPage();
          case AppRoute.cloze:
            return ClozePage(word: currentWord);
          case AppRoute.entryVocabulary:
            return VocabularyPage(
                word: currentWord,
                nextTap: () {
                  // if (WordProvider().shouldRemind()) {
                  //   Navigator.of(context)
                  //       .popAndPushNamed(AppRoute.reviewWords);
                  // } else {
                  //   WordProvider().nextStudyWord();
                  //   Navigator.of(context)
                  //       .popUntil(ModalRoute.withName(AppRoute.entry));
                  // }
                });
          case AppRoute.todayWords:
          // return WordListPage(words: WordProvider().subList());
          case AppRoute.reviewWords:
          // final reviews = WordProvider().remindWords();
          // return WordListPage(
          //     words: reviews,
          //     nextTap: () {
          //       WordProvider().nextStudyWord();
          //       Navigator.of(context)
          //           .popUntil(ModalRoute.withName(AppRoute.entry));
          //     });
          default:
            return const HomePage();
        }
      },
      maximumSize: const Size(300, 812.0), // Maximum size
      enabled: kIsWeb,
      backgroundColor: CupertinoColors.systemGrey.resolveFrom(context),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final provider = AppSettings.of(context).wordProvider;
    final uri = Uri.tryParse(settings.name!);
    final path = uri?.path;
    // return StreamBuilder(
    //   stream: provider?.provideWord,
    //   builder: (context, snapshot) {
    //     if (snapshot.data == null) {
    //       return FadeTransition(
    //         opacity: CurvedAnimation(
    //           parent: animation,
    //           curve: Curves.easeInOut,
    //         ),
    //         child: animation.status == AnimationStatus.reverse
    //             ? child
    //             : ScaleTransition(
    //                 scale: Tween(begin: 1.3, end: 1.0).animate(animation),
    //                 child: child),
    //       );
    //     }
    //     return
    //         // CupertinoPageTransition(
    //         //     primaryRouteAnimation: animation,
    //         //     secondaryRouteAnimation: secondaryAnimation,
    //         //     linearTransition: false,
    //         //     child: child);
    //         SlideTransition(
    //       position: Tween(begin: Offset.fromDirection(0), end: Offset.zero)
    //           .animate(CurvedAnimation(
    //         parent: animation,
    //         curve: Curves.linearToEaseOut,
    //         reverseCurve: Curves.easeInToLinear,
    //       )),
    //       textDirection: Directionality.of(context),
    //       transformHitTests: false,
    //       child: child,
    //     );
    //   },
    // );
    if (provider?.currentWord == null && Navigator.canPop(context)) {
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
