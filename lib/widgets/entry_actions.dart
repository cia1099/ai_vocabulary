import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../pages/report_popup.dart';
import '../pages/search_popup.dart';
import '../utils/shortcut.dart';

class EntryActions extends StatefulWidget {
  const EntryActions({
    super.key,
    required this.wordID,
    this.skipIndexes = const [],
  });
  final int wordID;
  final List<int> skipIndexes;

  @override
  State<EntryActions> createState() => _EntryActionsState();
}

class _EntryActionsState extends State<EntryActions> {
  var collect = false;
  @override
  void initState() {
    super.initState();
    if (!widget.skipIndexes.contains(1))
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Durations.long2, () {
          collect = MyDB.instance.getAcquaintance(widget.wordID).collect;
          setState(() {});
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: actions(widget.skipIndexes),
    );
  }

  @override
  void dispose() {
    if (!widget.skipIndexes.contains(1)) {
      MyDB.instance.updateAcquaintance(wordId: widget.wordID, collect: collect);
    }
    super.dispose();
  }

  void toggleCollection() {
    setState(() {
      collect ^= true;
    });
  }

  List<Widget> actions(List<int> skipIndexes) {
    final appBarIconSize = Theme.of(context).appBarTheme.actionsIconTheme?.size;
    // final navColor =
    //     CupertinoTheme.of(context).textTheme.navActionTextStyle.color;
    return [
      if (!skipIndexes.contains(0))
        GestureDetector(
            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  barrierDismissible: true,
                  maintainState: true,
                  barrierColor:
                      Theme.of(context).colorScheme.shadow.withOpacity(.4),
                  pageBuilder: (context, _, __) => const SearchPopUpPage(),
                  settings: const RouteSettings(name: AppRoute.searchWords),
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
            child: Icon(
              CupertinoIcons.search,
              size: appBarIconSize,
              // color: navColor,
            )),
      if (!skipIndexes.contains(1))
        GestureDetector(
            onTap: toggleCollection,
            child: collect
                ? Icon(
                    CupertinoIcons.star_fill,
                    color: CupertinoColors.systemYellow,
                    size: appBarIconSize,
                  )
                : Icon(
                    CupertinoIcons.star,
                    size: appBarIconSize,
                  )),
      if (!skipIndexes.contains(2))
        GestureDetector(
            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  barrierDismissible: true,
                  barrierColor:
                      Theme.of(context).colorScheme.shadow.withOpacity(.4),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ReportPopUpPage(wordID: widget.wordID),
                  // transitionDuration: Durations.medium1,
                  settings: const RouteSettings(name: AppRoute.menuPopup),
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
            child: Icon(
              CupertinoIcons.ellipsis_vertical,
              size: appBarIconSize,
            )),
    ];
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
  late final collectWord = MyDB.instance.getAcquaintance(widget.wordID);
  late int acquaint = collectWord.acquaint;
  String firstText = 'Unknown', secondText = 'Naive';

  @override
  void dispose() {
    MyDB().updateAcquaintance(wordId: widget.wordID, acquaint: acquaint);
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
        color: colorScheme.tertiaryContainer.withOpacity(.8),
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
                    style: TextStyle(color: colorScheme.onTertiaryContainer))),
            SizedBox(
              height: 12,
              child: VerticalDivider(
                color: colorScheme.onTertiaryContainer,
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
                          ? colorScheme.onTertiaryContainer
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
