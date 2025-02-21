import 'dart:math' show sqrt2;

import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/align_paragraph.dart';
import 'package:ai_vocabulary/widgets/imagen_dialog.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodyMedium
        ?.apply(color: colorScheme.onPrimaryContainer, fontSizeFactor: sqrt2);
    return AlignParagraph(
        xInterval: 4,
        mark: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: () => showPlatformDialog(
                  context: context,
                  builder: (context) => ImagenDialog(widget.example)),
              child: widget.mark ??
                  Icon(
                    CupertinoIcons.circle_fill,
                    size: textTheme.bodySmall?.fontSize
                        .scale(textTheme.bodySmall?.height),
                    color: colorScheme.primary,
                  ),
            )),
        paragraph: Text.rich(
            TextSpan(children: [
              TextSpan(
                  children: clickableWords(widget.example,
                      patterns: widget.patterns)),
              const TextSpan(text: '\t\t'),
              WidgetSpan(
                child: PlatformWidgetBuilder(
                  material: (_, child, __) => InkWell(
                      onTap: () => soundAzure(widget.example), child: child),
                  cupertino: (_, child, __) => GestureDetector(
                      onTap: () => soundAzure(widget.example), child: child),
                  child: Icon(
                    CupertinoIcons.volume_up,
                    size: textTheme.bodyLarge?.fontSize
                        .scale(textTheme.bodyLarge?.height),
                  ),
                ),
              )
            ]),
            style: style),
        paragraphStyle: style);
  }
}
