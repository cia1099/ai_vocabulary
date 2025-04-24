import 'package:ai_vocabulary/model/phrase.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../widgets/definition_tile.dart';
import '../../widgets/example_paragraph.dart';

class PhraseTab extends StatelessWidget {
  final Future<List<Phrase>> futurePhrases;
  final double hPadding;
  const PhraseTab({
    super.key,
    required this.futurePhrases,
    required this.hPadding,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        FutureBuilder(
          future: futurePhrases,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverFillRemaining(
                child: Center(
                  child: SpinKitFadingCircle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              );
            }
            final phrases = snapshot.data ?? <Phrase>[];
            //call tabNotice update state
            return SliverList.builder(
              itemCount: phrases.length,
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                return Container(
                  padding: EdgeInsets.only(
                    top: hPadding,
                    left: hPadding,
                    right: hPadding,
                  ),
                  margin:
                      index == phrases.length - 1
                          ? const EdgeInsets.only(
                            bottom: kBottomNavigationBarHeight,
                          )
                          : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            phrase.phrase,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                            ),
                          ),
                          ...phrase.definitions.map(
                            (definition) => Text(
                              definition.partOfSpeech,
                              style: textTheme.titleMedium!.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ).coloredSpeech(context: context),
                          ),
                        ],
                      ),
                      Divider(height: 4),
                      for (final definition in phrase.definitions)
                        for (final explain in definition.explanations) ...[
                          DefinitionParagraph(explain: explain),
                          ...explain.examples.map(
                            (example) => ExampleParagraph(
                              example: example,
                              patterns:
                                  phrase.phrase.split(' ') +
                                  (definition.inflection?.split(", ") ??
                                      <String>[]),
                            ),
                          ),
                        ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class TabPhrase extends StatelessWidget {
  final Future<List<Phrase>> futurePhrases;
  const TabPhrase({super.key, required this.futurePhrases});

  @override
  Widget build(BuildContext context) {
    // final textPainter = TextPainter(
    //   text: TextSpan(text: "Phrase"),
    //   maxLines: 1,
    //   textDirection: TextDirection.ltr,
    // )..layout();
    final colorScheme = Theme.of(context).colorScheme;
    return Tab(
      iconMargin: EdgeInsets.only(top: 8),
      child: SizedBox(
        width: 80, //textPainter.width * 1.76,
        child: Stack(
          children: [
            Center(child: Text("Phrase")),
            Align(
              alignment: Alignment(1, -.5),
              child: FutureBuilder(
                future: futurePhrases,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CupertinoActivityIndicator(radius: 10);
                  }
                  final phrases = snapshot.data ?? <Phrase>[];
                  if (phrases.isEmpty) return SizedBox.shrink();
                  return DecoratedBox(
                    decoration: ShapeDecoration(
                      color: colorScheme.secondaryContainer,
                      shape: CircleBorder(
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: SizedBox.square(
                      dimension: 20,
                      child: Center(
                        child: Text(
                          '${phrases.length}',
                          // style: DefaultTextStyle.of(context).style,
                          // Theme.of(context).textTheme.bodySmall?.copyWith(
                          //   color: Theme.of(context).colorScheme.onPrimaryContainer,
                          //   fontWeight: FontWeight.bold,
                          // ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool showNotice([int count = 0]) => count > 0;
}

class PinnedTabBar extends SliverPersistentHeaderDelegate {
  final List<Widget> tabs;

  PinnedTabBar({required this.tabs});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: 48,
      // color: Colors.green,
      child: TabBar.secondary(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        // labelPadding: EdgeInsets.zero,
        tabs: tabs,
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
