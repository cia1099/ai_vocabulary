import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ManageCollectionSheet extends StatelessWidget {
  const ManageCollectionSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final hPadding = MediaQuery.of(context).size.width / 32;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      minimum: EdgeInsets.symmetric(horizontal: hPadding / 2),
      child: DraggableScrollableSheet(
        expand: false,
        snap: true,
        maxChildSize: .9,
        minChildSize: .0,
        snapSizes: const [.45, .9],
        initialChildSize: .45,
        builder: (context, scrollController) => PlatformWidgetBuilder(
          material: (_, child, __) => child,
          cupertino: (_, child, __) => CupertinoPopupSurface(child: child),
          child: Column(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: hPadding),
                  height: kToolbarHeight,
                  decoration: BoxDecoration(
                      border: Border(
                          bottom:
                              BorderSide(color: colorScheme.outlineVariant))),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Add to favorite', style: textTheme.titleMedium),
                          PlatformIconButton(
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              material: (_, __) => MaterialIconButtonData(
                                    style: IconButton.styleFrom(
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              icon: const Wrap(
                                spacing: 8,
                                children: [
                                  Icon(CupertinoIcons.add_circled_solid),
                                  Text('New mark'),
                                ],
                              ))
                        ],
                      ),
                      Align(
                        alignment: const Alignment(0, -.8),
                        child: Container(
                          width: hPadding * 4,
                          height: 4,
                          decoration: BoxDecoration(
                              color: colorScheme.outline,
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemExtent: kToolbarHeight,
                itemBuilder: (context, index) => PlatformListTile(
                  key: ValueKey(index),
                  title: Container(
                      height: kToolbarHeight,
                      // color: Colors.red,
                      alignment: const Alignment(-1, 0),
                      child: Text('Item $index', style: textTheme.titleLarge)),
                  leading: PlatformWidget(
                    cupertino: (_, __) => CupertinoCheckbox(
                      value: false,
                      onChanged: (value) {},
                      checkColor: colorScheme.onPrimary,
                      fillColor: WidgetStateColor.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? colorScheme.primary
                            : const Color(0x00000000),
                      ),
                    ),
                    material: (_, __) => Checkbox(
                      value: false,
                      onChanged: (value) {},
                      checkColor: colorScheme.onPrimary,
                      fillColor: WidgetStateColor.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? colorScheme.primary
                            : const Color(0x00000000),
                      ),
                    ),
                  ),
                  trailing: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(CupertinoIcons.line_horizontal_3)),
                ),
                itemCount: 20,
                onReorder: (oldIndex, newIndex) {},
              )),
              Container(
                height: kToolbarHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: colorScheme.outlineVariant))),
                child: PlatformTextButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  material: (_, __) => MaterialTextButtonData(
                      style: TextButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
