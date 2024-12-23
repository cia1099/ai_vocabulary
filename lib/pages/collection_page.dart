import 'dart:math';

import 'package:ai_vocabulary/model/collection_mark.dart';
import 'package:ai_vocabulary/widgets/flashcard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../widgets/filter_input_bar.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final marks =
      List<BookMark>.generate(4, (i) => CollectionMark(name: '$i', index: i))
        ..add(SystemMark(name: 'add', index: 99));
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final gridKey = GlobalKey<SliverAnimatedGridState>();
  var destroy = false;
  SliverAnimatedGridState? get gridState => gridKey.currentState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gridState?.insertAllItems(0, marks.length,
          duration: Durations.extralong4);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    marks.sort((a, b) => a.index.compareTo(b.index));
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            PlatformSliverAppBar(
              stretch: true,
              title: const Text("My Collections"),
              backgroundColor: colorScheme.surfaceDim.withOpacity(.8),
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
              // cupertino: (_, __) => CupertinoSliverAppBarData(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: InputRowDelegate(
                maxHeight: kTextTabBarHeight + 10,
                context: context,
                focusNode: focusNode,
                child: FilterInputBar(
                  focusNode: focusNode,
                  controller: textController,
                  backgroundColor: colorScheme.surfaceDim.withOpacity(.8),
                  hintText: 'find it',
                  padding: EdgeInsets.only(
                      left: hPadding, right: hPadding, bottom: 10),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              sliver: ReorderableWrapperWidget(
                  dragEnabled: false,
                  onReorder: (oldIndex, newIndex) => setState(() {
                        onReorder(oldIndex, newIndex);
                      }),
                  isSliver: true,
                  dragWidgetBuilder: DragWidgetBuilderV2(
                      builder: (index, child, screenshot) => Material(
                          color: colorScheme.primary,
                          elevation: 4,
                          borderRadius:
                              BorderRadius.circular(kRadialReactionRadius),
                          child: child)),
                  child: SliverAnimatedGrid(
                    key: gridKey,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: hPadding,
                      crossAxisSpacing: hPadding,
                    ),
                    itemBuilder: (context, index, animation) => ScaleTransition(
                        scale: CurvedAnimation(
                            parent: animation, curve: Curves.bounceOut),
                        child: buildBookmark(marks[index])),
                    // initialItemCount: marks.length + 1,
                  )),
            ),
          ],
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
            for (final removedMark in marks) {
              if (removedMark is! CollectionMark) continue;
              gridState.removeItem(
                  0,
                  (context, animation) => FadeTransition(
                        opacity: CurvedAnimation(
                            parent: animation, curve: Curves.easeOut),
                        child: Flashcard(mark: removedMark),
                      ),
                  duration: Durations.medium1);
            }
            marks.removeWhere((m) => m is CollectionMark);
            Future.delayed(Durations.medium1, () {
              marks.insertAll(
                  0,
                  List.generate(Random().nextInt(4),
                      (i) => CollectionMark(name: '$i', index: i)));
              gridState.insertAllItems(
                  0, marks.whereType<CollectionMark>().length,
                  duration: Durations.extralong1);
            });
          },
          child: const Icon(CupertinoIcons.minus_circled)),
    );
  }

  Widget buildBookmark(BookMark bookmark) {
    return switch (bookmark) {
      CollectionMark _ => ReorderableItemView(
          key: Key(bookmark.name),
          index: marks.indexOf(bookmark),
          child: Flashcard(
            mark: bookmark,
            onRemove: onRemove,
          )),
      SystemMark _ => bookmark.index > 0
          ? Card.filled(
              child: Center(
                  child: FloatingActionButton.large(
                onPressed: () {
                  final lastIndex = marks.whereType<CollectionMark>().length;
                  var count = 0;
                  if (lastIndex > 0) {
                    count = marks
                        .whereType<CollectionMark>()
                        .map((m) => m.name.contains('Repository') ? 1 : 0)
                        .reduce((v1, v2) => v1 + v2);
                  }
                  final newMark = CollectionMark(
                      name:
                          'Repository${count > 0 ? '$count'.padLeft(2, '0') : ''}',
                      index: lastIndex);
                  marks.insert(lastIndex, newMark);
                  gridState?.insertItem(lastIndex,
                      duration: Durations.extralong1);
                },
                elevation: 2,
                shape: const CircleBorder(),
                child: const Icon(CupertinoIcons.add),
              )),
            )
          : InkWell(
              onTap: () {},
              child: Card.filled(
                child: Column(
                  children: [
                    Expanded(
                      child: Lottie.asset(
                        'assets/lottie/favorite.json',
                        repeat: false,
                      ),
                    ),
                    const Text(
                      'Uncategorized',
                      style: TextStyle(
                          // backgroundColor: Colors.green,
                          fontWeight: FontWeight.w600),
                      textScaler: TextScaler.linear(1.6),
                    )
                  ],
                ),
              ),
            ),
      _ => const Placeholder()
    };
  }

  void onRemove(CollectionMark mark) {
    final rmIndex = marks.indexOf(mark);
    final maxIndex = marks
        .whereType<CollectionMark>()
        .map((m) => m.index)
        .reduce((i1, i2) => max(i1, i2));
    onReorder(rmIndex, marks.indexWhere((m) => m.index == maxIndex));
    final removedMark = marks.removeAt(rmIndex) as CollectionMark;
    gridState?.removeItem(
        rmIndex,
        (context, animation) => FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: Flashcard(mark: removedMark),
            ),
        duration: Durations.extralong4);
  }

  void onReorder(oldIndex, newIndex) {
    marks[oldIndex].index = marks[newIndex].index;
    if (oldIndex < newIndex) {
      for (int i = oldIndex + 1; i <= newIndex; i++) {
        if (marks[i] is CollectionMark) marks[i].index--;
      }
    } else {
      for (int i = newIndex; i < oldIndex; i++) {
        if (marks[i] is CollectionMark) marks[i].index++;
      }
    }
  }
}

class InputRowDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final FocusNode focusNode;
  final BuildContext context;

  InputRowDelegate({
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
  bool shouldRebuild(covariant InputRowDelegate oldDelegate) => false;
}
