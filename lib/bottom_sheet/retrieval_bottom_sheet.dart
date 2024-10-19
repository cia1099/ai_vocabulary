import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class RetrievalBottomSheet extends StatelessWidget {
  const RetrievalBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: .1,
      maxChildSize: .95,
      snapSizes: const [.32, .9],
      initialChildSize: .32,
      builder: (context, scrollController) => PlatformWidgetBuilder(
        material: (_, child, ___) => child,
        cupertino: (_, child, ___) => Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16)),
            child: child),
        child: Column(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              child: Container(
                height: 32,
                padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Icon(CupertinoIcons.chevron_up_chevron_down),
                    GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(CupertinoIcons.xmark_circle_fill)),
                  ],
                ),
              ),
            ),
            Flexible(
                child: MediaQuery.removePadding(
              context: context,
              removeTop: platform(context) == PlatformTarget.iOS,
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  return PlatformListTile(title: Text('Item $index'));
                },
              ),
            )
                // SingleChildScrollView(
                //     // controller: scrollController,
                //     physics: BouncingScrollPhysics(),
                //     child: Column(
                //       children: List.generate(
                //         50,
                //         (index) => PlatformListTile(
                //             title: Text('Item $index')),
                //       ),
                //     )),
                ),
          ],
        ),
      ),
    );
  }
}
