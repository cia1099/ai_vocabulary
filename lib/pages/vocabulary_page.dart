import 'package:ai_vocabulary/model/vocabulary.dart';
import 'package:ai_vocabulary/widgets/definition_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class VocabularyPage extends StatelessWidget {
  const VocabularyPage({super.key, required this.word});

  final Vocabulary word;

  @override
  Widget build(BuildContext context) {
    // return SliverCase();
    double headerHeight = 150;
    final sliverColor = ColorTween(begin: Colors.grey, end: Colors.red);
    final textTheme = Theme.of(context).textTheme;
    final hPadding = MediaQuery.of(context).size.width / 16;
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
                        flexibleSpace: LayoutBuilder(
                          builder: (context, constraints) {
                            final height =
                                constraints.maxHeight - kToolbarHeight - 48;
                            // final borderRadius = Tween(end: 0.0, begin: 25.0);
                            final h = height / headerHeight;
                            return Column(
                              children: [
                                ClipRRect(
                                  child: Container(
                                      height: height + kToolbarHeight,
                                      // color: sliverColor.transform(h),
                                      child: CustomPaint(
                                        painter: h > 0
                                            ? RadialGradientPainter(
                                                colorScheme: Theme.of(context)
                                                    .colorScheme)
                                            : null,
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: Transform.scale(
                                                  scale: h + 1,
                                                  child: Text(word.word,
                                                      style: textTheme
                                                          .headlineMedium)),
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
                                      )),
                                ),
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

class SliverCase extends StatelessWidget {
  const SliverCase({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          body: NestedScrollView(
              physics: BouncingScrollPhysics(),
              headerSliverBuilder: (context, innerScrolled) => <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverAppBar(
                          pinned: true,
                          stretch: true,
                          title: Text('username'),
                          expandedHeight: 325,
                          toolbarHeight: 0,
                          flexibleSpace: FlexibleSpaceBar(
                              stretchModes: <StretchMode>[
                                StretchMode.zoomBackground,
                                StretchMode.blurBackground,
                              ],
                              background: Image.network(
                                  'https://i.imgur.com/QCNbOAo.png',
                                  fit: BoxFit.cover)),
                          bottom: TabBar(
                              tabs: <Widget>[Text('test1'), Text('test2')])),
                    )
                  ],
              body: TabBarView(children: [
                Center(
                  child: Builder(
                    builder: (context) => CustomScrollView(
                      slivers: <Widget>[
                        SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context)),
                        SliverFixedExtentList(
                            delegate: SliverChildBuilderDelegate(
                                (_, index) => Text('not working $index'),
                                childCount: 100),
                            itemExtent: 25)
                      ],
                    ),
                  ),
                ),
                Center(child: Text('working'))
              ])),
        ));
  }
}

class SliverAppBarExample extends StatefulWidget {
  const SliverAppBarExample({super.key});

  @override
  State<SliverAppBarExample> createState() => _SliverAppBarExampleState();
}

class _SliverAppBarExampleState extends State<SliverAppBarExample> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;

// [SliverAppBar]s are typically used in [CustomScrollView.slivers], which in
// turn can be placed in a [Scaffold.body].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: _pinned,
            snap: _snap,
            floating: _floating,
            expandedHeight: 160.0,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('SliverAppBar'),
              background: FlutterLogo(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
              child: Center(
                child: Text('Scroll to see the SliverAppBar in effect.'),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  color: index.isOdd ? Colors.white : Colors.black12,
                  height: 100.0,
                  child: Center(
                    child:
                        Text('$index', textScaler: const TextScaler.linear(5)),
                  ),
                );
              },
              childCount: 20,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            overflowAlignment: OverflowBarAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('pinned'),
                  Switch(
                    onChanged: (bool val) {
                      setState(() {
                        _pinned = val;
                      });
                    },
                    value: _pinned,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('snap'),
                  Switch(
                    onChanged: (bool val) {
                      setState(() {
                        _snap = val;
                        // Snapping only applies when the app bar is floating.
                        _floating = _floating || _snap;
                      });
                    },
                    value: _snap,
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('floating'),
                  Switch(
                    onChanged: (bool val) {
                      setState(() {
                        _floating = val;
                        _snap = _snap && _floating;
                      });
                    },
                    value: _floating,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomLayoutDelegate extends SingleChildLayoutDelegate {
  final double sliverHeight;
  final dOffset = Tween<Offset>(end: Offset.zero, begin: Offset(50, 0));
  CustomLayoutDelegate(this.sliverHeight);

  // @override
  // BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
  //   final height = constraints.maxHeight - kToolbarHeight;
  //   final size = SizeTween(
  //       end: Size(constraints.maxWidth, sliverHeight + kToolbarHeight),
  //       begin: Size(50, 50));
  //   return BoxConstraints.tight(
  //       size.transform(height / sliverHeight) ?? constraints.biggest);
  // }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final height = size.height - kToolbarHeight;
    return dOffset.transform(height / sliverHeight);
  }

  @override
  bool shouldRelayout(covariant CustomLayoutDelegate oldDelegate) =>
      sliverHeight != oldDelegate.sliverHeight;
}
