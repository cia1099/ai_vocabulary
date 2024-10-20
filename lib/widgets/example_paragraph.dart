import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../utils/clickable_text_mixin.dart';

class ExampleParagraph extends StatefulWidget {
  const ExampleParagraph({
    super.key,
    required this.example,
    required this.patterns,
  });

  final String example;
  final Iterable<String> patterns;

  @override
  State<ExampleParagraph> createState() => _ExampleParagraphState();
}

class _ExampleParagraphState extends State<ExampleParagraph>
    with ClickableTextStateMixin {
  final textExpanded = GlobalKey();
  double? leftSideHeight;
  late final colorScheme = Theme.of(context).colorScheme;
  late final textTheme = Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => setState(() {
        final renderBox =
            textExpanded.currentContext?.findRenderObject() as RenderBox;
        leftSideHeight = renderBox.size.height;
        // print(leftSideHeight);
      }),
    );
    onTap = <T>(_) => Future<T>.delayed(Durations.long2);
  }

  @override
  Widget build(BuildContext context) {
    final bodyText = textTheme.bodyMedium!;
    // print(bodyText.fontSize! * bodyText.height!);
    final padding = leftSideHeight == null
        ? 0.0
        : (leftSideHeight! - bodyText.fontSize! * bodyText.height!)
            .clamp(0.0, leftSideHeight!);
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: Container(
            // color: Colors.red,
            padding: EdgeInsets.only(bottom: padding),
            height: leftSideHeight,
            child: Icon(
              CupertinoIcons.circle_fill,
              size: textTheme.bodySmall!.fontSize,
              color: colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    children: clickableWords(widget.example,
                        patterns: widget.patterns)),
                const TextSpan(text: '\t\t'),
                WidgetSpan(
                  child: PlatformWidgetBuilder(
                    material: (_, child, __) =>
                        InkWell(onTap: () {}, child: child),
                    cupertino: (_, child, __) =>
                        GestureDetector(onTap: () {}, child: child),
                    child: Icon(CupertinoIcons.volume_up,
                        size: textTheme.bodyLarge!.fontSize),
                  ),
                )
              ]),
              key: textExpanded,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
              )),
        ),
      ],
    );
  }
}
