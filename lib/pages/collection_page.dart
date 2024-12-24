import 'dart:async';
import 'dart:math';

import 'package:ai_vocabulary/model/collection_mark.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
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
  late List<BookMark> marks = fetchDB;

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final gridKey = GlobalKey<SliverAnimatedGridState>();
  var preventQuicklyChanged = Timer(Duration.zero, () {});
  var destroy = false;
  SliverAnimatedGridState? get gridState => gridKey.currentState;
  List<BookMark> get fetchDB => List<BookMark>.generate(
      4, (i) => CollectionMark(name: '${i & 1}$i', index: i));
  List<BookMark> get systemMark => [
        SystemMark(name: 'add', index: kMaxInt64),
        SystemMark(name: 'uncategory', index: -1)
      ];

  @override
  void initState() {
    super.initState();
    marks.addAll(systemMark);
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
    return PlatformScaffold(
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
                  padding: EdgeInsets.only(
                      left: hPadding, right: hPadding, bottom: 10),
                  focusNode: focusNode,
                  controller: textController,
                  backgroundColor: colorScheme.surfaceDim.withOpacity(.8),
                  hintText: 'find it',
                  onChanged: (p0) {
                    preventQuicklyChanged.cancel();
                    preventQuicklyChanged =
                        Timer(Durations.medium4, () => filterMark(p0));
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              sliver: ReorderableWrapperWidget(
                  // dragEnabled: false,
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
                        child:
                            buildBookmark(marks[index], textController.text)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void filterMark(String query) {
    if (query.isEmpty && marks.whereType<SystemMark>().isNotEmpty) return;
    final queryMarks = fetchDB.where((m) => m.name.contains(query));
    for (final removedMark in marks) {
      gridState?.removeItem(
          0,
          (context, animation) => FadeTransition(
                opacity:
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                child: buildBookmark(removedMark),
              ),
          duration: Durations.short4);
    }
    Future.delayed(Durations.short4, () {
      marks = queryMarks.toList();
      if (query.isEmpty && marks.whereType<SystemMark>().isEmpty) {
        marks.addAll(systemMark);
      }
      marks.sort((a, b) => a.index.compareTo(b.index));
      gridState?.insertAllItems(0, marks.length, duration: Durations.long1);
      // setState(() {
      //   // If we don't use setState to sort marks,
      //   // we need to explicit sort mark and then
      //   // the call of gridState?.insertAllItems() can
      //   // be directly called, no WidgetsBinding wrap.
      //     gridState?.insertAllItems(0, marks.length, duration: Durations.long1);
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //   });
      // });
    });
  }

  Widget buildBookmark(BookMark bookmark, [String filter = '']) {
    return switch (bookmark) {
      CollectionMark _ => ReorderableItemView(
          key: Key(bookmark.name),
          index: marks.indexOf(bookmark),
          child: Flashcard(
            mark: bookmark,
            filter: filter,
            onRemove: onRemove,
          )),
      SystemMark _ => bookmark.index > 0
          ? Card.filled(
              child: Center(
                  child: FloatingActionButton.large(
                onPressed: () {
                  final insertIndex = marks.length - 1;
                  var count = 0;
                  if (marks.whereType<CollectionMark>().isNotEmpty) {
                    count = marks
                        .whereType<CollectionMark>()
                        .map((m) => m.name.contains('Repository') ? 1 : 0)
                        .reduce((v1, v2) => v1 + v2);
                  }
                  final newMark = CollectionMark(
                      name:
                          'Repository${count > 0 ? '$count'.padLeft(2, '0') : ''}',
                      index: insertIndex);
                  marks.insert(insertIndex, newMark);
                  gridState?.insertItem(insertIndex,
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
