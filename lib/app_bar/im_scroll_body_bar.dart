import 'package:flutter/material.dart';

class ImScrollBodyBar extends StatelessWidget {
  final Widget? child;
  final Widget pinnedBar;
  final Widget scrollBody;
  final double? height;
  final ScrollController? controller;
  final void Function(double height)? monitorHeight;
  const ImScrollBodyBar({
    super.key,
    this.child,
    this.height,
    required this.pinnedBar,
    required this.scrollBody,
    this.monitorHeight,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final pinnedColor = ColorTween(
        begin: Theme.of(context).scaffoldBackgroundColor,
        end: Theme.of(context).scaffoldBackgroundColor);
    final defaultHeight = height ??
        MediaQueryData.fromView(View.of(context)).size.height -
            48 -
            kToolbarHeight;
    return NestedScrollView(
      floatHeaderSlivers: true,
      controller: controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          pinned: true,
          excludeHeaderSemantics: true,
          automaticallyImplyLeading: false,
          toolbarHeight: 48,
          elevation: 0,
          expandedHeight: defaultHeight + 48,
          flexibleSpace: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight - 48;
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                monitorHeight?.call(height);
              });
              return Column(
                children: [
                  Container(
                    height: height,
                    alignment: Alignment.bottomCenter,
                    // color: Colors.green,
                    child: Opacity(
                        opacity: (height / defaultHeight).clamp(0, 1.0),
                        child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: scrollBody)),
                  ),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                        color: pinnedColor.transform(height / defaultHeight),
                        border: Border(bottom: BorderSide(color: Colors.grey))),
                    child: pinnedBar,
                  ),
                ],
              );
            },
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      ],
      body: child ?? Placeholder(),
    );
  }
}
