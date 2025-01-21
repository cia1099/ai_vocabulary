import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/bottom_sheet/manage_collection.dart';
import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../effects/automated_pop_route.dart';
import '../pages/add_collection_island.dart';
import '../pages/report_popup.dart';
import '../pages/search_popup.dart';
import '../utils/function.dart';
import '../utils/shortcut.dart';

class EntryActions extends StatelessWidget {
  const EntryActions({
    super.key,
    required this.wordID,
    this.skipIndexes = const [],
  });
  final int wordID;
  final List<int> skipIndexes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: actions(skipIndexes, context),
    );
  }

  List<Widget> actions(List<int> skipIndexes, BuildContext context) {
    final appBarIconSize = Theme.of(context).appBarTheme.actionsIconTheme?.size;
    final colorScheme = Theme.of(context).colorScheme;
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
                      colorScheme.inverseSurface.withValues(alpha: .4),
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
        FavoriteStar(wordID: wordID, size: appBarIconSize),
      if (!skipIndexes.contains(2))
        GestureDetector(
            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                  opaque: false,
                  barrierDismissible: true,
                  barrierColor:
                      colorScheme.inverseSurface.withValues(alpha: .4),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ReportPopUpPage(wordID: wordID),
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

class FavoriteStar extends StatelessWidget {
  const FavoriteStar({
    super.key,
    required this.wordID,
    this.size,
  });

  final int wordID;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MyDB.instance,
      builder: (context, child) {
        final collect = MyDB().hasCollectWord(wordID);
        return GestureDetector(
            onTap: toggleCollectionMethods(collect, context),
            child: Hero(
              tag: 'favorite_$wordID',
              child: Icon(
                collect ? CupertinoIcons.star_fill : CupertinoIcons.star,
                color: collect
                    ? CupertinoColors.systemYellow.resolveFrom(context)
                    : null,
                size: size,
              ),
              flightShuttleBuilder: (flightContext, animation, flightDirection,
                      fromHeroContext, toHeroContext) =>
                  ScaleTransition(
                scale: PeakQuadraticTween().animate(animation),
                child: toHeroContext.widget,
              ),
            ));
      },
    );
  }

  VoidCallback toggleCollectionMethods(
      final bool hasCollection, BuildContext context) {
    if (!hasCollection) {
      return () {
        MyDB().addCollectWord(wordID);
        Navigator.push(
            context,
            AutomatedPopRoute(
              stay: const Duration(milliseconds: 1500),
              barrierColor: Theme.of(context)
                  .colorScheme
                  .inverseSurface
                  .withValues(alpha: .12),
              builder: (context) => AddCollectionIsland(
                wordID: wordID,
                onPressed: () => showManageCollectionSheet(context),
              ),
            ));
      };
    } else {
      return () => showManageCollectionSheet(context);
    }
  }

  void showManageCollectionSheet(BuildContext context) {
    showPlatformModalSheet(
      context: context,
      builder: (context) => ManageCollectionSheet(wordID: wordID),
    );
  }
}

class NaiveSegment extends StatefulWidget {
  const NaiveSegment({
    super.key,
    required this.word,
  });

  final Vocabulary word;

  @override
  State<NaiveSegment> createState() => _NaiveSegmentState();
}

class _NaiveSegmentState extends State<NaiveSegment> {
  late int acquaint = MyDB().getAcquaintance(widget.word.wordId).acquaint;
  String firstText = 'Unknown', secondText = 'Naive';

  @override
  void dispose() {
    MyDB().updateAcquaintance(wordId: widget.word.wordId, acquaint: acquaint);
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
    secondText = acquaint == widget.word.acquaint ? 'Naive' : 'withdraw';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer.withValues(alpha: .8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GestureDetector(
                onTap: acquaint > 0 ? resetLearned : null,
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
                onTap: acquaint == widget.word.acquaint ? setNaive : withdraw,
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
      acquaint = widget.word.acquaint;
    });
  }
}
