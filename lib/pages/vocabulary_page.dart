import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/app_route.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
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
                            textTheme: textTheme),
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
    required this.textTheme,
  });

  final double headerHeight;
  final Vocabulary word;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
                          delegate: BackGroudLayoutDelegate(headerHeight),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(
                                borderRadius.transform(h),
                              ),
                            ),
                          ),
                        ),
                        CustomPaint(
                          foregroundPainter: TitlePainter(
                            title: word.word,
                            headerHeight: headerHeight,
                            style: textTheme.headlineMedium,
                          ),
                          size: constraints.biggest,
                        ),
                        Align(
                            alignment: FractionalOffset(.98, h / 2.5 + .5),
                            child: const Wrap(
                                spacing: 8,
                                children: [Text("Unknow"), Text("Naive")])),
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

class BackGroudLayoutDelegate extends SingleChildLayoutDelegate {
  final double headerHeight;
  BackGroudLayoutDelegate(
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
  bool shouldRelayout(covariant BackGroudLayoutDelegate oldDelegate) => false;
}

class TitlePainter extends CustomPainter {
  final String title;
  final double headerHeight;
  final TextStyle? style;

  TitlePainter(
      {super.repaint,
      required this.title,
      required this.headerHeight,
      this.style});
  @override
  void paint(Canvas canvas, Size size) {
    final h = (size.height - kToolbarHeight) / headerHeight;
    final textPainter = TextPainter(
        maxLines: 1,
        ellipsis: '...',
        textScaler: TextScaler.linear(1 + h),
        text: TextSpan(text: title, style: style),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: size.width);
    final textRect = Offset.zero & textPainter.size;
    final dOffset = Tween<Offset>(
        end: Offset(16, headerHeight) - textRect.centerLeft / 2,
        begin: Offset(size.width / 2, 0) +
            textRect.centerLeft / 2 -
            textRect.topRight / 2);
    textPainter.paint(canvas, dOffset.transform(h));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
