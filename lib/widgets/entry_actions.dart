import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/collect_word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/report_popup.dart';
import '../pages/search_popup.dart';

class EntryActions extends StatefulWidget {
  const EntryActions({
    super.key,
    required this.wordID,
  });
  final int wordID;

  @override
  State<EntryActions> createState() => _EntryActionsState();
}

class _EntryActionsState extends State<EntryActions> {
  late var collect = MyDB.instance.getCollectWord(widget.wordID).collect;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Wrap(
        spacing: 8,
        children: [
          GestureDetector(
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    barrierDismissible: true,
                    barrierColor:
                        Theme.of(context).colorScheme.shadow.withOpacity(.4),
                    pageBuilder: (context, _, __) => const SearchPopUpPage(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            AnimatedBuilder(
                                animation: animation,
                                builder: (_, __) => Transform.scale(
                                      alignment: Alignment.topCenter,
                                      origin: const Offset(0, 32),
                                      scaleY: animation.value,
                                      child: child,
                                    )),
                  )),
              child: const Icon(CupertinoIcons.search)),
          GestureDetector(
              onTap: toggleCollection,
              child: collect
                  ? const Icon(CupertinoIcons.star_fill,
                      color: CupertinoColors.systemYellow)
                  : const Icon(CupertinoIcons.star)),
          GestureDetector(
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                    opaque: false,
                    barrierDismissible: true,
                    barrierColor:
                        Theme.of(context).colorScheme.shadow.withOpacity(.4),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ReportPopUpPage(),
                    // transitionDuration: Durations.medium1,
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      final matrix = Matrix4Tween(
                        end: Matrix4.identity(),
                        begin: Matrix4.diagonal3Values(1, .1, 1)
                          ..translate(.0, 1e3),
                      ).chain(CurveTween(curve: Curves.easeOut));
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) => Transform(
                          alignment: Alignment.topCenter,
                          transform: matrix.evaluate(animation),
                          child: child,
                        ),
                      );
                    },
                  )),
              child: const Icon(CupertinoIcons.ellipsis_vertical)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    MyDB.instance.updateCollectWord(wordId: widget.wordID, collect: collect);
    super.dispose();
  }

  void toggleCollection() {
    setState(() {
      collect ^= true;
    });
  }
}

class NaiveSegment extends StatefulWidget {
  const NaiveSegment({
    super.key,
    required this.wordID,
  });

  final int wordID;

  @override
  State<NaiveSegment> createState() => _NaiveSegmentState();
}

class _NaiveSegmentState extends State<NaiveSegment> {
  late final collectWord = MyDB.instance.getCollectWord(widget.wordID);
  late int acquaint = collectWord.acquaint;
  String firstText = 'Unknown', secondText = 'Naive';

  @override
  void dispose() {
    MyDB().updateCollectWord(wordId: widget.wordID, acquaint: acquaint);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    firstText = acquaint == 0
        ? 'Learn in future'
        : acquaint < kMaxAcquaintance
            ? 'Unknown'
            : "Don't learn anymore";
    secondText =
        acquaint > 0 && acquaint < kMaxAcquaintance ? 'Naive' : 'withdraw';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
                onTap: acquaint > 0 && acquaint < 5 ? resetLearned : null,
                child: Text.rich(
                    TextSpan(children: [
                      WidgetSpan(
                          child: Offstage(
                              offstage: firstText != 'Unknown',
                              child:
                                  const Icon(CupertinoIcons.escape, size: 16))),
                      const TextSpan(text: ' '),
                      TextSpan(text: firstText),
                    ]),
                    style: TextStyle(color: colorScheme.onPrimaryContainer))),
            SizedBox(
              height: 12,
              child: VerticalDivider(
                color: colorScheme.onSecondaryContainer,
                width: 8,
              ),
            ),
            GestureDetector(
                onTap: acquaint > 0 && acquaint < 5 ? setNaive : withdraw,
                child: Text.rich(
                  TextSpan(children: [
                    WidgetSpan(
                        child: Offstage(
                            offstage: secondText != 'Naive',
                            child:
                                const Icon(CupertinoIcons.smiley, size: 16))),
                    const TextSpan(text: ' '),
                    TextSpan(text: secondText),
                  ]),
                  style: TextStyle(
                      color: secondText != 'withdraw'
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.primary),
                ))
          ]),
    );
  }

  void resetLearned() {
    setState(() {
      acquaint = 0;
    });
  }

  void setNaive() {
    setState(() {
      acquaint = kMaxAcquaintance;
    });
  }

  void withdraw() {
    setState(() {
      if (collectWord.acquaint > 0 && collectWord.acquaint < kMaxAcquaintance) {
        acquaint = collectWord.acquaint;
      } else if (collectWord.acquaint == 0) {
        acquaint = (++collectWord.acquaint).clamp(0, kMaxAcquaintance - 1);
      } else {
        acquaint = (--collectWord.acquaint).clamp(0, kMaxAcquaintance - 1);
      }
    });
  }
}
