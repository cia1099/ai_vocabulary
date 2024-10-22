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
    double headerHeight = 200;
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
                                Container(
                                    alignment: Alignment.center,
                                    height: height + kToolbarHeight,
                                    color: sliverColor.transform(h),
                                    child: Transform.scale(
                                        scale: h + 1,
                                        child: Text(word.word,
                                            style: textTheme.headlineMedium))),
                                Container(
                                  // color: Colors.green,
                                  height: 48,
                                  child: TabBar.secondary(
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
