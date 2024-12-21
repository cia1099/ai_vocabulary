import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

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
            ListenableBuilder(
              listenable: focusNode,
              builder: (context, child) => SliverPersistentHeader(
                pinned: focusNode.hasFocus,
                delegate: ShrinkRowDelegate(
                  maxHeight: kTextTabBarHeight + 10,
                  pinned: focusNode.hasFocus,
                  child: child!,
                ),
              ),
              child: Container(
                color: colorScheme.surface.withOpacity(.8),
                padding: EdgeInsets.only(
                    left: hPadding, right: hPadding, bottom: 10),
                child: ListenableBuilder(
                  listenable: focusNode,
                  builder: (context, child) => Wrap(
                    children: [
                      AnimatedContainer(
                        duration: Durations.short4,
                        width: hPadding * 32 -
                            hPadding * 2 -
                            (focusNode.hasFocus ? 64 : 0),
                        height: kTextTabBarHeight,
                        decoration: BoxDecoration(
                            color: colorScheme.onInverseSurface,
                            borderRadius: BorderRadius.circular(
                                kRadialReactionRadius / 2)),
                        child: PlatformTextField(
                          hintText: 'find it',
                          controller: textController,
                          focusNode: focusNode,
                          cupertino: (_, __) => CupertinoTextFieldData(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                            prefix: const Icon(CupertinoIcons.equal_square,
                                color: CupertinoColors.systemGrey4),
                          ),
                          material: (_, __) => MaterialTextFieldData(
                            decoration: const InputDecoration(
                              fillColor: Colors.transparent,
                              prefix: Icon(CupertinoIcons.equal_square,
                                  color: CupertinoColors.systemGrey4),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                      AnimatedSize(
                        duration: Durations.short4,
                        child: SizedBox(
                          width: focusNode.hasFocus ? 64 : 0,
                          height: 48,
                          child: PlatformTextButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                textController.clear();
                                focusNode.unfocus();
                              },
                              material: (_, __) => MaterialTextButtonData(
                                      style: IconButton.styleFrom(
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  )),
                              child: const Text('Cancel')),
                        ),
                      )
                    ],
                  ),
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
  final bool pinned;
  final Key? key;

  ShrinkRowDelegate(
      {this.key,
      required this.child,
      required this.maxHeight,
      this.pinned = false});

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
    return ConstrainedBox(
      key: key,
      constraints: BoxConstraints(maxHeight: maxExtent),
      child: child,
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => pinned ? maxExtent : 0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
