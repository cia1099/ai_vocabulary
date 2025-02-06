import 'package:ai_vocabulary/api/dict_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:text2speech/text2speech.dart';

import '../bottom_sheet/retrieval_bottom_sheet.dart';
import '../model/vocabulary.dart';
import '../utils/clickable_text_mixin.dart';
import 'example_paragraph.dart';

class DefinitionTile extends StatelessWidget {
  const DefinitionTile({
    super.key,
    required this.definition,
    required this.word,
  });

  final Definition definition;
  final String word;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PartOfSpeechTitle(definition: definition, word: word),
        const Divider(height: 4),
        if (definition.inflection != null)
          Wrap(
            spacing: 8,
            children: definition.inflection!
                .split(", ")
                .toSet()
                .map((e) => Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
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
            (example) {
              final explainWord = explain.explain.split(' ');
              return ExampleParagraph(
                  example: example,
                  patterns: definition.inflection?.split(", ") ??
                      [word] + (explainWord.length == 1 ? explainWord : []));
            },
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final subscript = widget.explain.subscript == null
        ? ''
        : '[${widget.explain.subscript!}]\t';
    final spans = clickableWords(subscript + widget.explain.explain);
    final firstSpan = clickableWords(subscript);
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

class PartOfSpeechTitle extends StatelessWidget {
  const PartOfSpeechTitle({
    super.key,
    required this.definition,
    required this.word,
  });

  final Definition definition;
  final String word;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(definition.partOfSpeech,
            style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold)),
        if (definition.phoneticUk != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇬🇧${definition.phoneticUk!}', style: textTheme.bodyLarge),
              PlatformWidgetBuilder(
                material: (_, child, __) => InkWell(
                    onTap: playPhonetic(definition.audioUk,
                        word: word, gTTs: gTTS.UK),
                    child: child),
                cupertino: (_, child, __) => GestureDetector(
                    onTap: playPhonetic(definition.audioUk,
                        word: word, gTTs: gTTS.UK),
                    child: child),
                child: Icon(CupertinoIcons.volume_up,
                    size: textTheme.bodyLarge!.fontSize),
              ),
            ],
          ),
        if (definition.phoneticUs != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇺🇸${definition.phoneticUs!}', style: textTheme.bodyLarge),
              PlatformWidgetBuilder(
                material: (_, child, __) => InkWell(
                    onTap: playPhonetic(definition.audioUs, word: word),
                    child: child),
                cupertino: (_, child, __) => GestureDetector(
                    onTap: playPhonetic(definition.audioUs, word: word),
                    child: child),
                child: Icon(CupertinoIcons.volume_up,
                    size: textTheme.bodyLarge!.fontSize),
              ),
            ],
          ),
      ],
    );
  }
}

VoidCallback playPhonetic(String? url,
    {required String word, gTTS gTTs = gTTS.US}) {
  return url != null
      ? () => immediatelyPlay(url, 'audio/mp3')
      : () => soundGTTs(word, gTTs);
}
