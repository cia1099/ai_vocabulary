import 'dart:math';

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

part 'views/definition_tab.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key, required this.word, this.nextTap});

  final Vocabulary word;
  final VoidCallback? nextTap;

  @override
  Widget build(BuildContext context) {
    double headerHeight = 150;
    final hPadding = MediaQuery.of(context).size.width / 16;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //TODO: push page will incur this callback
      final example = word.getExamples.firstOrNull;
      final routeName = ModalRoute.of(context)?.settings.name;
      if (example != null && fromEntry(routeName)) {
        Future.delayed(Durations.medium1, () => soundAzure(example));
      }
    });
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 1,
          child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverAppBar(
                        expandedHeight: headerHeight + kToolbarHeight + 48,
                        toolbarHeight: kToolbarHeight + 48,
                        pinned: true,
                        flexibleSpace: VocabularyHead(
                          headerHeight: headerHeight,
                          word: word,
                        ),
                        leading: const SizedBox(),
                      ),
                    ),
                  ],
              body: Stack(
                children: [
                  TabBarView(children: [
                    DefinitionTab(word: word, hPadding: hPadding),
                  ]),
                  Align(
                    alignment: const FractionalOffset(.5, 1),
                    child: Offstage(
                      offstage: nextTap == null,
                      child: PlatformElevatedButton(
                        onPressed: () {
                          nextTap!();
                          Navigator.of(context)
                              .popUntil(ModalRoute.withName(AppRoute.entry));
                        },
                        child: const Text('Next'),
                      ),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

class VocabularyHead extends StatelessWidget {
  const VocabularyHead({
    super.key,
    required this.headerHeight,
    required this.word,
  });

  final double headerHeight;
  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final navigatorTheme =
        CupertinoTheme.of(context).textTheme.navActionTextStyle;
    final routeName = ModalRoute.of(context)?.settings.name;
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight - kToolbarHeight - 48;
        final borderRadius = Tween(end: 0.0, begin: kToolbarHeight);
        final h = height / headerHeight;
        return Column(
          children: [
            SizedBox(
                height: height + kToolbarHeight,
                child: ClipRRect(
                  child: CustomPaint(
                    painter: h > 0
                        ? RadialGradientPainter(
                            colorScheme: Theme.of(context).colorScheme)
                        : null,
                    child: Stack(
                      children: [
                        CustomSingleChildLayout(
                          delegate: BackgroundLayoutDelegate(headerHeight),
                          child: Container(
                            decoration: BoxDecoration(
                              image: word.asset != null
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(word.asset!))
                                  : null,
                              // color: Colors.blue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(
                                borderRadius.transform(h),
                              ),
                            ),
                          ),
                        ),
                        if (routeName != null)
                          ...List.from([
                            Positioned(
                                top: 16,
                                left: 0,
                                child: GestureDetector(
                                  onTap: Navigator.of(context).pop,
                                  child: Icon(
                                    CupertinoIcons.chevron_back,
                                    color: navigatorTheme.color,
                                    size: 32,
                                  ),
                                )),
                            Positioned(
                                top: 16,
                                right: 0,
                                child: EntryActions(wordID: word.wordId)),
                            Positioned(
                                bottom: 0,
                                right: 0,
                                child: Offstage(
                                  offstage: h < .1,
                                  child: NaiveSegment(wordID: word.wordId),
                                )),
                          ]).take(fromEntry(routeName) ? 3 : 1),
                        CustomPaint(
                          foregroundPainter: TitlePainter(
                            title: word.word,
                            headerHeight: headerHeight,
                            style: textTheme.headlineMedium,
                            strokeColor: colorScheme.outlineVariant,
                          ),
                          size: constraints.biggest,
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(
              // color: Colors.green,
              height: 48,
              child: TabBar.secondary(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(
                        text: "Definition",
                        iconMargin: EdgeInsets.only(top: 8)),
                  ]),
            ),
          ],
        );
      },
    );
  }
}

class BackgroundLayoutDelegate extends SingleChildLayoutDelegate {
  final double headerHeight;
  BackgroundLayoutDelegate(
    this.headerHeight,
  );

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final height = constraints.maxHeight - kToolbarHeight;
    final size = SizeTween(
        end: Size(constraints.maxWidth, headerHeight + kToolbarHeight),
        begin: const Size(0, kToolbarHeight));
    return BoxConstraints.tight(
        size.transform(height / headerHeight) ?? constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final dOffset =
        Tween<Offset>(end: Offset.zero, begin: Offset(size.width / 2, 0));
    final height = size.height - kToolbarHeight;
    return dOffset.transform(height / headerHeight);
  }

  @override
  bool shouldRelayout(covariant BackgroundLayoutDelegate oldDelegate) => false;
}

class TitlePainter extends CustomPainter {
  final String title;
  final double headerHeight;
  final TextStyle? style;
  final Color? strokeColor;

  TitlePainter(
      {super.repaint,
      required this.title,
      required this.headerHeight,
      this.strokeColor,
      this.style});
  @override
  void paint(Canvas canvas, Size size) {
    final h = (size.height - kToolbarHeight) / headerHeight;
    final opacity = h > .05 && h < .25 ? .0 : 1.0;
    final textPainter = TextPainter(
        maxLines: 1,
        ellipsis: '...',
        textScaler: TextScaler.linear(1 + h),
        text: TextSpan(
          text: title,
          style: style?.apply(
            //TODO: apply below code will casue flutter bug
            color: style?.color?.withOpacity(opacity),
            shadows: List.generate(
                4,
                (i) => Shadow(
                    offset: Offset.fromDirection(pi * (1 + 2 * i) / 4, 2),
                    color: strokeColor?.withOpacity(h < .25 ? .0 : h) ??
                        kDefaultIconLightColor)),
          ),
        ),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width);

    final textRect = Offset.zero & textPainter.size;
    final dOffset = Tween<Offset>(
        end: Offset(16, headerHeight - 16) - textRect.centerLeft / 2,
        begin: Offset(size.width / 2, 0) +
            textRect.centerLeft / 2 -
            textRect.topRight / 2);
    textPainter.paint(canvas, dOffset.transform(h));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
