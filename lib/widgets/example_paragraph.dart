import 'package:ai_vocabulary/widgets/align_paragraph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../utils/clickable_text_mixin.dart';

class ExampleParagraph extends StatefulWidget {
  const ExampleParagraph({
    super.key,
    required this.example,
    required this.patterns,
    this.mark,
  });

  final String example;
  final Iterable<String> patterns;
  final Widget? mark;

  @override
  State<ExampleParagraph> createState() => _ExampleParagraphState();
}

class _ExampleParagraphState extends State<ExampleParagraph>
    with ClickableTextStateMixin {
  late final colorScheme = Theme.of(context).colorScheme;
  late final textTheme = Theme.of(context).textTheme;

  @override
  void initState() {
    super.initState();
    onTap = <T>(word) => showPlatformModalSheet<T>(
          context: context,
          material: MaterialModalSheetData(
            useSafeArea: true,
            isScrollControlled: true,
          ),
          builder: (context) => RetrievalBottomSheet(queryWord: word),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AlignParagraph(
        markWidget: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: widget.mark ??
              Icon(
                CupertinoIcons.circle_fill,
                size: textTheme.bodySmall!.fontSize,
                color: colorScheme.primary,
              ),
        ),
        paragraph: Text.rich(
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
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
            )),
        xInterval: 0);
  }
}
