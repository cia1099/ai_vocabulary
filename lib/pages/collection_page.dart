import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = List.generate(20, (i) => i);

    return PlatformScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          PlatformSliverAppBar(
            stretch: true,
            title: const Text("My Collections"),
            material: (_, __) => MaterialSliverAppBarData(pinned: true),
            cupertino: (_, __) => CupertinoSliverAppBarData(),
          ),
        ],
        body: ReorderableWrapperWidget(
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final element = data.removeAt(oldIndex);
              data.insert(newIndex, element);
            },
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) => index < data.length
                  ? ReorderableItemView(
                      key: ValueKey(index),
                      index: index,
                      child: collectBuilder(index))
                  : const Card.filled(
                      child: Icon(CupertinoIcons.add),
                    ),
              itemCount: data.length + 1,
            )),
      ),
    );
  }

  Widget collectBuilder(int index) {
    return Container(
      color: index.isOdd ? Colors.white : Colors.black12,
      // height: 100.0,
      alignment: const Alignment(0, 0),
      child: Text('$index', textScaler: const TextScaler.linear(5.0)),
    );
  }
}
