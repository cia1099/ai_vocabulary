import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key, required this.word});

  final Vocabulary word;

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
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final height =
                                constraints.maxHeight - kToolbarHeight - 48;
                            final borderRadius =
                                Tween(end: 0.0, begin: kToolbarHeight);
                            final h = height / headerHeight;
                            return Column(
                              children: [
                                Container(
                                    height: height + kToolbarHeight,
                                    child: ClipRRect(
                                      child: CustomPaint(
                                        painter: h > 0
                                            ? RadialGradientPainter(
                                                colorScheme: Theme.of(context)
                                                    .colorScheme)
                                            : null,
                                        child: Stack(
                                          children: [
                                            CustomSingleChildLayout(
                                              delegate: BackGroudLayoutDelegate(
                                                  headerHeight),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                                alignment: FractionalOffset(
                                                    .98, h / 2.5 + .5),
                                                child: Wrap(
                                                    spacing: 8,
                                                    children: [
                                                      Text("Unknow"),
                                                      Text("Naive")
                                                    ])),
                                          ],
                                        ),
                                      ),
                                    )),
                                Container(
                                  // color: Colors.green,
                                  height: 48,
                                  child: const TabBar.secondary(
                                      isScrollable: true,
                                      tabAlignment: TabAlignment.start,
                                      tabs: [
                                        Tab(
                                            text: "Definition",
                                            iconMargin:
                                                EdgeInsets.only(top: 8)),
                                      ]),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
              body: TabBarView(children: [
                Builder(
                  builder: (context) => CustomScrollView(
                    slivers: <Widget>[
                      SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context)),
                      SliverList.builder(
                          itemCount: word.definitions.length,
                          itemBuilder: (_, index) => Container(
                                padding: EdgeInsets.only(
                                  top: hPadding,
                                  left: hPadding,
                                  right: hPadding,
                                ),
                                margin: index == word.definitions.length - 1
                                    ? const EdgeInsets.only(
                                        bottom: kBottomNavigationBarHeight)
                                    : null,
                                child: DefinitionTile(
                                    definition: word.definitions[index],
                                    word: word.word),
                              )),
                    ],
                  ),
                ),
              ])),
        ),
      ),
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
        begin: Size(0, kToolbarHeight));
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

class RadialGradientPainter extends CustomPainter {
  final ColorScheme colorScheme;

  RadialGradientPainter({super.repaint, required this.colorScheme});
  @override
  void paint(Canvas canvas, Size size) {
    // 定义径向渐变
    final Rect rect = Offset.zero & size;
    final RadialGradient gradient1 = RadialGradient(
      center: const Alignment(.9, -.9), // 中心位置
      radius: 1, // 渐变的半径
      colors: [
        colorScheme.inversePrimary,
        colorScheme.onInverseSurface,
        colorScheme.inversePrimary,
        // Colors.transparent,
      ],
      stops: [0.0, 0.6, .8], // 每个颜色的分布位置
    );
    final RadialGradient gradient2 = RadialGradient(
      center: Alignment(-1, 1),
      radius: 1, // 渐变的半径
      colors: [
        colorScheme.inversePrimary,
        colorScheme.onInverseSurface,
        colorScheme.inversePrimary,
        // Colors.transparent,
      ],
      stops: [0.0, 0.6, .8], // 每个颜色的分布位置
    );

    // 创建 Paint 对象，并设置 shader 为径向渐变
    // final Paint paint = Paint()..shader = gradient.createShader(rect);

    // 在画布上绘制矩形并填充渐变
    // canvas.drawRect(rect, paint);
    canvas.drawCircle(Offset(size.width, 0), size.height / 2,
        Paint()..shader = gradient1.createShader(rect));
    canvas.drawCircle(Offset(0, size.height), size.height / 2,
        Paint()..shader = gradient2.createShader(rect));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // 因为我们不需要重绘，所以返回 false
  }
}
