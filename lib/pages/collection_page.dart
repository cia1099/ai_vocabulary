import 'dart:async';

import 'package:ai_vocabulary/database/my_db.dart';
import 'package:ai_vocabulary/model/collections.dart';
import 'package:ai_vocabulary/utils/function.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/flashcard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

import '../effects/pointer_down_physic.dart';
import '../widgets/filter_input_bar.dart';
import 'favorite_words_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  late List<BookMark> marks = fetchDB.toList();

  final textController = TextEditingController();
  final focusNode = FocusNode();
  final gridKey = GlobalKey<SliverAnimatedGridState>();
  Timer? preventQuicklyChanged;
  var reverse = 1;
  var onFlip = false, dragEnabled = false;

  SliverAnimatedGridState? get gridState => gridKey.currentState;
  Iterable<BookMark> get fetchDB => MyDB().fetchMarks();
  List<BookMark> get systemMark => [
        SystemMark(name: 'add', index: kMaxInt64),
        SystemMark(name: 'Uncategorized', index: -1)
      ];

  @override
  void initState() {
    super.initState();
    marks.addAll(systemMark);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gridState?.insertAllItems(0, marks.length,
          duration: Durations.extralong4);
    });
    MyDB().addListener(updateOrderListener);
  }

  @override
  void dispose() {
    MyDB().removeListener(updateOrderListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    marks.sort((a, b) => a.index.compareTo(b.index) * reverse);
    return PlatformScaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            PlatformSliverAppBar(
              stretch: true,
              title: const Text("My Collections"),
              backgroundColor: kCupertinoSheetColor.resolveFrom(context),
              material: (_, __) => MaterialSliverAppBarData(
                  pinned: true,
                  actions: actions(),
                  flexibleSpace: const FlexibleSpaceBar(
                    stretchModes: [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                      StretchMode.fadeTitle,
                    ],
                    // background: FlutterLogo(),
                  )),
              cupertino: (_, __) => CupertinoSliverAppBarData(
                  trailing: Wrap(
                spacing: 4,
                children: actions(),
              )),
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
                  backgroundColor: colorScheme.surface,
                  hintText: 'find it',
                  onChanged: (p0) {
                    preventQuicklyChanged?.cancel();
                    preventQuicklyChanged =
                        Timer(Durations.medium4, () => filterMark(p0));
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              sliver: ReorderableWrapperWidget(
                  dragEnabled: dragEnabled,
                  onReorder: (oldIndex, newIndex) {
                    if (marks.whereType<SystemMark>().isNotEmpty)
                      setState(() {
                        onReorder(oldIndex, newIndex);
                      });
                  },
                  isSliver: true,
                  dragWidgetBuilder:
                      DragWidgetBuilderV2(builder: (index, child, screenshot) {
                    return PhysicalModel(
                        color: colorScheme.primary,
                        elevation: 8,
                        borderRadius:
                            BorderRadius.circular(kRadialReactionRadius),
                        child: child);
                  }),
                  child: SliverAnimatedGrid(
                    key: gridKey,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: hPadding,
                      crossAxisSpacing: hPadding,
                    ),
                    itemBuilder: (context, index, animation) => onFlip
                        ? MatrixTransition(
                            animation: SineTween().animate(animation),
                            onTransform: (angle) => Matrix4.rotationY(angle),
                            child: buildBookmark(
                                marks[index], textController.text))
                        : ScaleTransition(
                            scale: CurvedAnimation(
                                parent: animation, curve: Curves.bounceOut),
                            child: buildBookmark(
                                marks[index], textController.text)),
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
    var i = 0;
    for (final removedMark in marks) {
      if (queryMarks.contains(removedMark)) {
        i++;
        continue;
      }
      gridState?.removeItem(
          i,
          (context, animation) => ScaleTransition(
                scale: CurvedAnimation(
                    parent: animation, curve: Curves.easeInOutBack),
                child: buildBookmark(removedMark),
              ),
          duration: Durations.short4);
    }
    marks.retainWhere((m) => queryMarks.contains(m));
    final retainMark = List.from(marks);
    Future.delayed(Durations.short4, () {
      for (final newMark in queryMarks) {
        if (!marks.contains(newMark)) {
          marks.add(newMark);
        }
      }
      if (query.isEmpty && marks.whereType<SystemMark>().isEmpty) {
        marks.addAll(systemMark);
      }
      marks.sort((a, b) => a.index.compareTo(b.index) * reverse);
      final insertIndexes = marks
          .asMap()
          .entries
          .where((e) => !retainMark.contains(e.value))
          .map((e) => e.key);
      for (final index in insertIndexes)
        gridState?.insertItem(index, duration: Durations.long1);
    });
  }

  void flipReverseOrder() {
    preventQuicklyChanged?.cancel();
    setState(() {
      onFlip = true;
    });
    reverse *= -1;
    for (final removedMark in marks) {
      gridState?.removeItem(
          0,
          (context, animation) => ValueListenableBuilder(
                valueListenable: SineTween().animate(animation),
                builder: (context, value, child) => Transform(
                  transform: Matrix4.rotationY(value),
                  alignment: const Alignment(0, 0),
                  child: child,
                ),
                child: buildBookmark(removedMark),
              ),
          duration: Durations.short4);
    }
    Timer(Durations.short4, () {
      marks.sort((a, b) => a.index.compareTo(b.index) * reverse);
      gridState?.insertAllItems(0, marks.length, duration: Durations.long1);
      preventQuicklyChanged = Timer(Durations.long2, () {
        setState(() {
          onFlip = false;
        });
      });
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
            dragEnabled: dragEnabled,
          )),
      SystemMark _ => bookmark.index > 0
          ? Card.filled(
              child: Center(
                  child: FloatingActionButton.large(
                onPressed: () {
                  final insertIndex = reverse < 0 ? 1 : marks.length - 1;
                  var count = 0;
                  final repoNames = marks
                      .where((m) => m.name.contains('Repository'))
                      .map((m) => m.name);
                  if (repoNames.isNotEmpty) {
                    final nameNumbers = repoNames
                        .map(
                            (name) => RegExp(r'\d+').firstMatch(name)?.group(0))
                        .map((digit) => int.tryParse(digit ?? '') ?? 0);
                    for (; nameNumbers.contains(count); count++) {}
                  }
                  final newMark = CollectionMark(
                      name:
                          'Repository${count > 0 ? '$count'.padLeft(2, '0') : ''}',
                      index: marks.whereType<CollectionMark>().length);
                  marks.insert(insertIndex, newMark);
                  gridState?.insertItem(insertIndex,
                      duration: Durations.extralong1);
                  MyDB().insertCollection(newMark.name, newMark.index);
                },
                elevation: 2,
                shape: const CircleBorder(),
                child: const Icon(CupertinoIcons.add),
              )),
            )
          : OnPointerDownPhysic(
              child: Card.filled(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      platformPageRoute(
                          context: context,
                          builder: (context) => FavoriteWordsPage(
                                mark: CollectionMark(
                                  name: kUncategorizedName,
                                  index: bookmark.index,
                                  icon: CupertinoIcons.star.codePoint,
                                ),
                              ))),
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
            ),
      _ => const Placeholder()
    };
  }

  List<Widget> actions() {
    return [
      PlatformIconButton(
        onPressed: dragEnabled ? null : flipReverseOrder,
        icon: const Icon(CupertinoIcons.arrow_2_squarepath),
        padding: EdgeInsets.zero,
        material: (_, __) => MaterialIconButtonData(
          style: IconButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      PlatformTextButton(
        onPressed: () => setState(() {
          dragEnabled ^= true;
        }),
        padding: EdgeInsets.zero,
        material: (_, __) => MaterialTextButtonData(
          style: TextButton.styleFrom(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        child: Text(dragEnabled ? 'Done' : 'Revise'),
      )
    ];
  }

  void updateOrderListener() {
    final updatedMarks = fetchDB;
    var hasUpdated = false;
    for (var i = 0; i < marks.length; i++) {
      final updatedMark = updatedMarks
          .where((m) => m == marks[i] && m.index != marks[i].index)
          .firstOrNull;
      if (updatedMark != null) {
        marks[i].index = updatedMark.index;
        hasUpdated = true;
      }
    }
    if (hasUpdated) setState(() {});
  }

  void onRemove(CollectionMark mark) {
    final rmIndex = marks.indexOf(mark);
    final removedMark = marks.removeAt(rmIndex) as CollectionMark;
    //TODO: current solution, bad implement because side effect
    final backup = List.of(marks);
    marks = fetchDB.toList() //guarantee marks are CollectionMark type
      ..sort((a, b) => a.index.compareTo(b.index) * reverse);
    //onReoder() changes the member marks,
    if (reverse > 0) {
      onReorder(marks.indexOf(removedMark), marks.length - 1);
    } else {
      onReorder(marks.indexOf(removedMark), 0);
    }
    marks = backup;
    gridState?.removeItem(
        rmIndex,
        (context, animation) => FadeTransition(
              opacity:
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: Flashcard(mark: removedMark),
            ),
        duration: Durations.extralong4);
    MyDB().removeMark(name: removedMark.name);
  }

  void onReorder(oldIndex, newIndex) {
    marks[oldIndex].index = marks[newIndex].index;
    if (oldIndex < newIndex) {
      for (int i = oldIndex + 1; i <= newIndex; i++) {
        if (marks[i] is CollectionMark) marks[i].index -= reverse;
      }
    } else {
      for (int i = newIndex; i < oldIndex; i++) {
        if (marks[i] is CollectionMark) marks[i].index += reverse;
      }
    }
    MyDB().updateIndexes(marks.whereType<CollectionMark>());
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
