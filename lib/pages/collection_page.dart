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
  final data = List.generate(20, (i) => i);
  final textController = TextEditingController();
  final focusNode = FocusNode();
  final gridKey = GlobalKey<AnimatedGridState>();

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    return PlatformScaffold(
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
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
            ReorderableWrapperWidget(
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final element = data.removeAt(oldIndex);
                  data.insert(newIndex, element);
                },
                child: SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  sliver: SliverAnimatedGrid(
                    key: gridKey,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: hPadding,
                      crossAxisSpacing: hPadding,
                    ),
                    itemBuilder: (context, index, animation) => FadeTransition(
                      opacity: CurvedAnimation(
                          parent: animation, curve: Curves.easeOut),
                      child: index < data.length
                          ? ReorderableItemView(
                              key: ValueKey(index),
                              index: index,
                              child: collectBuilder(index))
                          : const Card.filled(
                              child: Icon(CupertinoIcons.add),
                            ),
                    ),
                    initialItemCount: data.length + 1,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget collectBuilder(int index) {
    return Card(
      color: index.isOdd ? Colors.white : Colors.black12,
      // height: 100.0,
      // alignment: const Alignment(0, 0),
      child: Center(
          child: Text('$index', textScaler: const TextScaler.linear(5.0))),
    );
  }
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
