import 'dart:async';
import 'dart:convert';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/effects/show_toast.dart';
import 'package:ai_vocabulary/effects/transient.dart'
    show CupertinoDialogTransition;
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/utils/handle_except.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

abstract class LoadingRoute<T, S> extends PageRoute<T> {
  Stream<T> loading(S src);

  @override
  final Color? barrierColor;
  late final S src;
  final Widget Function(BuildContext context, T data) builder;

  LoadingRoute({
    required this.builder,
    this.barrierColor = kCupertinoModalBarrierColor,
    super.settings,
  });

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final bs = loading(src).asBroadcastStream();
    return FutureBuilder(
      future: bs.first,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var lastData = snapshot.data as T;
          scheduleMicrotask(
            () => Navigator.pushReplacement(
              context,
              platformPageRoute(
                context: context,
                settings: settings,
                fullscreenDialog: isMaterial(context),
                builder:
                    (context) => StreamBuilder(
                      initialData: lastData,
                      stream: bs,
                      builder: (context, p) {
                        if (p.data != null) {
                          lastData = p.data as T;
                        }
                        if (p.hasError) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => showToast(
                              context: context,
                              child: Text(messageExceptions(p.error)),
                            ),
                          );
                        }
                        return builder(context, p.data ?? lastData);
                      },
                    ),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          scheduleMicrotask(() => Navigator.maybePop(context));
        }
        final msg = snapshot.hasError ? messageExceptions(snapshot.error) : '';
        return DummyDialog(msg: msg);
      },
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return CupertinoDialogTransition(animation: animation, child: child);
  }

  @override
  bool get maintainState => false;

  @override
  String? get barrierLabel => 'Loading holding';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);

  @override
  bool get barrierDismissible => false;

  @override
  bool get opaque => false;
}

class WordListRoute extends LoadingRoute<List<Vocabulary>, Iterable<int>> {
  WordListRoute({
    required final Iterable<int> wordIDs,
    required super.builder,
    super.barrierColor,
    super.settings,
  }) {
    super.src = wordIDs;
  }

  @override
  Stream<List<Vocabulary>> loading(Iterable<int> wordIDs) {
    return loadWordList(wordIDs);
  }
}

class WordRoute extends LoadingRoute<Vocabulary, int> {
  WordRoute({
    required int wordID,
    required super.builder,
    super.barrierColor,
    super.settings,
  }) {
    super.src = wordID;
  }

  @override
  Stream<Vocabulary> loading(int wordID) async* {
    await MyDB().isReady;
    final words = MyDB().fetchWords([wordID]);
    if (words.isNotEmpty) {
      yield words.first;
    } else {
      final word = await getWordById(wordID);
      MyDB().insertWords(Stream.value(word));
      yield word;
    }
  }
}

Stream<List<Vocabulary>> loadWordList(Iterable<int> wordIDs) async* {
  await MyDB().isReady;
  final words = MyDB().fetchWords(wordIDs);
  if (words.isNotEmpty || wordIDs.isEmpty) {
    yield words;
  }
  final fetchSet = words.map((w) => w.wordId).toSet();
  final remainIDs = wordIDs.toSet().difference(fetchSet);
  final errorMap = <int, String>{};
  if (remainIDs.isNotEmpty) {
    const count = 20;
    final futureWords = <Future<List<Vocabulary>>>[];
    for (
      var i = 0, ids = remainIDs.skip(i).take(count);
      ids.isNotEmpty;
      ids = remainIDs.skip(++i * count).take(count)
    ) {
      futureWords.add(
        getWords(ids).onError((e, _) {
          errorMap.addAll({i: messageExceptions(e)});
          return [];
        }),
      );
    }
    final wordLists = Stream.fromFutures(futureWords).asBroadcastStream();
    MyDB().insertWords(
      wordLists.asyncExpand((list) => Stream.fromIterable(list)),
    );
    await for (final remainWords in wordLists) {
      words.addAll(remainWords);
    }
    yield words;
  }
  if (errorMap.isNotEmpty) {
    final msg = "Failed get ${errorMap.length} times.\n${jsonEncode(errorMap)}";
    throw ApiException(msg);
  }
}

// class ShitRoute extends LoadingRoute<String, int> {
//   ShitRoute({required super.builder}) {
//     super.src = 0;
//   }

//   @override
//   Stream<String> loading(int src) async* {
//     await Future.delayed(Duration(seconds: 1));
//     yield "first";
//     await Future.delayed(Duration(milliseconds: 100));
//     // await Future.delayed(Duration(seconds: 1));
//     // yield "second";
//     // await Future.delayed(Duration(seconds: 1));
//     // yield "third";
//     // await Future.delayed(Duration(seconds: 1));
//     yield "fourth";
//   }
// }
