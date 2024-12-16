import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/pages/chat_room_page.dart';
import 'package:ai_vocabulary/painters/bubble_arrow.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:ai_vocabulary/widgets/entry_actions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../painters/title_painter.dart';

part 'views/definition_tab.dart';

class VocabularyPage extends StatelessWidget {
  VocabularyPage({super.key, required this.word, this.nextTap}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final example = word.getExamples.firstOrNull;
      if (example != null) {
        Future.delayed(Durations.medium1, () => soundAzure(example));
      }
    });
  }

  final Vocabulary word;
  final VoidCallback? nextTap;

  @override
  Widget build(BuildContext context) {
    double headerHeight = 150;
    final hPadding = MediaQuery.of(context).size.width / 16;
    final routeName = ModalRoute.of(context)?.settings.name;
    return PlatformScaffold(
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
                        onPressed: nextTap,
                        child: const Text('Next'),
                      ),
                    ),
                  ),
                  Align(
                    alignment: const FractionalOffset(.95, .95),
                    child: Offstage(
                      offstage: routeName == null,
                      child: CustomPaint(
                        foregroundPainter: BubbleArrowPainter(
                            color: Theme.of(context).colorScheme.primary),
                        child: FloatingActionButton(
                          onPressed: () {
                            final path = p.join(
                                p.dirname(routeName ?? ''), AppRoute.chatRoom);
                            Navigator.of(context).push(platformPageRoute(
                                context: context,
                                settings: RouteSettings(name: path),
                                builder: (context) =>
                                    ChatRoomPage(word: word)));
                          },
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(kRadialReactionRadius)),
                          child: Icon(CupertinoIcons.chat_bubble_text,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ),
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
                              top: 0,
                              left: 0,
                              child: CupertinoNavigationBarBackButton(
                                onPressed: Navigator.of(context).pop,
                                previousPageTitle: 'Back',
                              ),
                            ),
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
                          ]).take(fromEntry(routeName) ? 3 : 2),
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
