import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../widgets/filter_input_bar.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final marks = List.generate(3, (i) => CollectionMark(name: '$i', index: i));
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final gridKey = GlobalKey<AnimatedGridState>();
  var destroy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gridKey.currentState
          ?.insertAllItems(0, marks.length + 1, duration: Durations.extralong4);
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(marks.map((e) => '${e.index}').join(', '));
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    marks.sort((a, b) => a.index.compareTo(b.index));
    return Scaffold(
      body: SafeArea(
        top: false,
        child: NestedScrollView(
          clipBehavior: Clip.antiAlias,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            PlatformSliverAppBar(
              stretch: true,
              title: const Text("My Collections"),
              backgroundColor: colorScheme.surface.withOpacity(.8),
              material: (_, __) => MaterialSliverAppBarData(
                  pinned: true,
                  flexibleSpace: const FlexibleSpaceBar(
                    stretchModes: [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: FlutterLogo(),
                  )),
              cupertino: (_, __) => CupertinoSliverAppBarData(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: ShrinkRowDelegate(
                maxHeight: kTextTabBarHeight + 10,
                context: context,
                focusNode: focusNode,
                child: FilterInputBar(
                  focusNode: focusNode,
                  controller: textController,
                  backgroundColor: colorScheme.surface.withOpacity(.8),
                  hintText: 'find it',
                  padding: EdgeInsets.only(
                      left: hPadding, right: hPadding, bottom: 10),
                ),
              ),
            ),
          ],
          body: ReorderableWrapperWidget(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    for (int i = oldIndex; i < newIndex; i++) {
                      marks[i + 1].index--;
                    }
                  } else {
                    for (int i = newIndex; i < oldIndex; i++) {
                      marks[i].index++;
                    }
                  }
                  marks[oldIndex].index = newIndex;
                });
              },
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: AnimatedGrid(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  key: gridKey,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    mainAxisSpacing: hPadding,
                    crossAxisSpacing: hPadding,
                  ),
                  itemBuilder: (context, index, animation) => ScaleTransition(
                    scale: CurvedAnimation(
                        parent: animation, curve: Curves.bounceOut),
                    child: index < marks.length
                        ? ReorderableItemView(
                            key: Key(marks[index].name),
                            index: index,
                            child: collectBuilder(int.parse(marks[index].name)))
                        : const Card.filled(
                            child: Icon(CupertinoIcons.add),
                          ),
                  ),
                  // initialItemCount: marks.length + 1,
                ),
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            destroy ^= true;
            final gridState = gridKey.currentState!;
            // if (destroy) {
            // gridState.removeAllItems(
            //   (context, animation) => FadeTransition(
            //     opacity:
            //         CurvedAnimation(parent: animation, curve: Curves.easeOut),
            //     child: const Card(child: Placeholder()),
            //   ),
            // );
            for (var removedMark in marks) {
              gridState.removeItem(
                  0,
                  (context, animation) => FadeTransition(
                        opacity: CurvedAnimation(
                            parent: animation, curve: Curves.easeOut),
                        child: collectBuilder(int.parse(removedMark.name)),
                      ),
                  duration: Durations.short3);
            }
            marks.clear();
            Future.delayed(Durations.short3, () {
              marks.addAll(List.generate(Random().nextInt(4),
                  (i) => CollectionMark(name: '$i', index: i)));
              gridState.insertAllItems(0, marks.length,
                  duration: Durations.extralong1);
            });
            // } else {
            // }
          },
          child: const Icon(CupertinoIcons.minus_circled)),
    );
  }

  Widget collectBuilder(int index) {
    return Card(
      // key: ValueKey(index),
      color: index.isOdd ? Colors.white : Colors.black12,
      child: Center(
          child: Text('$index', textScaler: const TextScaler.linear(5.0))),
    );
  }
}

class CollectionMark {
  final String name;
  int index;

  CollectionMark({required this.name, required this.index});
}

class ShrinkRowDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final FocusNode focusNode;
  final BuildContext context;

  ShrinkRowDelegate({
    required this.child,
    required this.context,
    required this.maxHeight,
    required this.focusNode,
  }) {
    focusNode.addListener(() {
      build(context, maxExtent, true);
    });
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // final padding = MediaQuery.paddingOf(context);
    // return Transform.translate(
    //     offset: Offset(
    //         0,
    //         overlapsContent
    //             ? (Platform.isIOS
    //                     ? kMinInteractiveDimensionCupertino
    //                     : kMinInteractiveDimension) +
    //                 padding.top
    //             : 0),
    //     child: ConstrainedBox(
    //       constraints: BoxConstraints(maxHeight: maxExtent),
    //       child: child,
    //     ));
    // return child;
    // print('shirnk = $shrinkOffset, overlap = $overlapsContent');
    if (overlapsContent && !focusNode.hasFocus)
      return SizedBox.fromSize(size: Size.fromHeight(maxExtent - shrinkOffset));
    return child;
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => focusNode.hasFocus ? maxExtent : 0;

  @override
  bool shouldRebuild(covariant ShrinkRowDelegate oldDelegate) => false;
}
