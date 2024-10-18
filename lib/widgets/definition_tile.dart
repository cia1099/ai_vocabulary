import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../model/vocabulary.dart';
import '../utils/clicable_text_mixin.dart';

class DefinitionTile extends StatelessWidget {
  const DefinitionTile({
    super.key,
    required this.definition,
  });

  final Definition definition;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(definition.partOfSpeech,
                style: textTheme.titleLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            if (definition.phoneticUk != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇬🇧${definition.phoneticUk!}',
                      style: textTheme.bodyLarge),
                  InkWell(
                    onTap: () {},
                    child: Icon(CupertinoIcons.volume_up,
                        size: textTheme.bodyLarge!.fontSize),
                  ),
                ],
              ),
            if (definition.phoneticUs != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🇺🇸${definition.phoneticUs!}',
                      style: textTheme.bodyLarge),
                  InkWell(
                    onTap: () {},
                    child: Icon(CupertinoIcons.volume_up,
                        size: textTheme.bodyLarge!.fontSize),
                  ),
                ],
              ),
          ],
        ),
        const Divider(height: 4),
        if (definition.inflection != null)
          Wrap(
            spacing: 8,
            children: definition.inflection!
                .split(", ")
                .toSet()
                .map((e) => Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(
                              textTheme.bodyMedium!.fontSize!)),
                      child: Text(e,
                          style:
                              TextStyle(color: colorScheme.onPrimaryContainer)),
                    ))
                .toList(),
          ),
        if (definition.translate != null) Text(definition.translate!),
        for (final explain in definition.explanations) ...[
          DefinitionParagraph(explain: explain),
          ...explain.examples.map(
            (example) => ExampleParagraph(example: example),
          ),
        ]
      ],
    );
  }
}

class DefinitionParagraph extends StatefulWidget {
  const DefinitionParagraph({
    super.key,
    required this.explain,
  });

  final Explanation explain;

  @override
  State<DefinitionParagraph> createState() => _DefinitionParagraphState();
}

class _DefinitionParagraphState extends State<DefinitionParagraph>
    with ClickableTextStateMixin {
  @override
  void initState() {
    super.initState();
    onTap = <T>(_) => Future<T>.delayed(Durations.long2);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final spans = clickableWords(
        '[${widget.explain.subscript!}]\t' + widget.explain.explain);
    final firstSpan = clickableWords('[${widget.explain.subscript!}]\t');
    return Text.rich(
      TextSpan(children: [
        if (widget.explain.subscript != null)
          TextSpan(
              children: spans.getRange(0, firstSpan.length).toList(),
              style: textTheme.bodyLarge!.apply(color: colorScheme.primary)),
        TextSpan(
            children: spans.getRange(firstSpan.length, spans.length).toList(),
            style: textTheme.bodyLarge!
                .copyWith(fontWeight: FontWeight.bold, height: 1.25)),
      ]),
    );
  }
}

class ExampleParagraph extends StatefulWidget {
  const ExampleParagraph({
    super.key,
    required this.example,
  });

  final String example;

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
                TextSpan(children: clickableWords(widget.example)),
                const TextSpan(text: '\t\t'),
                WidgetSpan(
                  child: InkWell(
                    onTap: () {},
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
