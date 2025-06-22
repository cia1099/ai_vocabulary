import 'dart:math' show pi;

import 'package:ai_vocabulary/app_settings.dart';
import 'package:ai_vocabulary/pages/payment_page.dart';
import 'package:ai_vocabulary/utils/enums.dart';
import 'package:ai_vocabulary/utils/phonetic.dart' show playPhonetic;
import 'package:ai_vocabulary/utils/shortcut.dart';
import 'package:ai_vocabulary/widgets/inline_paragraph.dart';
import 'package:ai_vocabulary/widgets/translate_request.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:text2speech/text2speech.dart';

import '../api/dict_api.dart';
import '../model/vocabulary.dart';
import '../utils/clickable_text_mixin.dart';
import '../utils/function.dart' show ScaleDouble;
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
                .map(
                  (e) => Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        textTheme.bodyMedium!.fontSize!,
                      ),
                    ),
                    child: Text(
                      e,
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                )
                .toList(),
          ),
        if (AppSettings.of(context).translator != TranslateLocate.none)
          TranslateRequest(
            request: (locate) => definitionTranslation(definition.id, locate),
            initialData: definition.translate,
            errorHandler: (error) => error is ApiException
                ? GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      platformPageRoute(
                        context: context,
                        fullscreenDialog: true,
                        builder: (context) => PaymentPage(),
                      ),
                    ),
                    child: Text(
                      'Go to Enable Translation',
                      style: TextStyle(
                        color: colorScheme.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                : null,
          ),
        for (final explain in definition.explanations) ...[
          DefinitionParagraph(explain: explain),
          ...explain.examples.map((example) {
            final explainWord = explain.explain.split(' ');
            return ExampleParagraph(
              mark: CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: textTheme.bodySmall?.fontSize
                    .scale(textTheme.bodySmall?.height)
                    .scale(.5),
                child: Icon(
                  CupertinoIcons.photo,
                  size: textTheme.labelSmall?.fontSize.scale(.9),
                  color: colorScheme.onPrimary,
                ),
              ),
              example: example,
              patterns:
                  definition.inflection?.split(", ") ??
                  [word] + (explainWord.length == 1 ? explainWord : []),
            );
          }),
        ],
        if (definition.synonyms != null || definition.antonyms != null) ...[
          SizedBox(height: 16),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(width: pi, color: colorScheme.inverseSurface),
              borderRadius: BorderRadius.circular(kRadialReactionRadius),
            ),
            child: CupertinoPopupSurface(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                width: double.infinity,
                // constraints: BoxConstraints(
                //   minHeight:
                //       textTheme.titleSmall?.fontSize
                //           .scale(textTheme.titleSmall?.height)
                //           .scale(1.5) ??
                //       0,
                // ),
                child: synAntonymBlock(context, textTheme, colorScheme),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget synAntonymBlock(
    BuildContext context,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (definition.synonyms != null)
          InlineParagraph(
            mark: BoxText(
              text: "Synonyms",
              style: textTheme.titleSmall,
              color: colorScheme.primary,
            ),
            markColor: colorScheme.primary,
            paragraph: definition.synonyms!.replaceAll(', ', ' / '),
            paragraphStyle: textTheme.labelLarge?.copyWith(
              height: 1.618,
              fontWeight: FontWeight.w600,
            ),
          ),
        if (definition.synonyms != null && definition.antonyms != null)
          Padding(
            padding: const EdgeInsets.only(left: 80, top: 4, bottom: 4),
            child: DottedLine(dashColor: colorScheme.outline),
          ),
        if (definition.antonyms != null)
          InlineParagraph(
            mark: BoxText(
              text: "Antonyms",
              style: textTheme.titleSmall,
              color: colorScheme.tertiary,
            ),
            markColor: colorScheme.tertiary,
            paragraph: definition.antonyms!.replaceAll(', ', ' / '),
            paragraphStyle: textTheme.labelLarge?.copyWith(
              height: 1.618,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

class DefinitionParagraph extends StatefulWidget {
  const DefinitionParagraph({super.key, required this.explain});

  final Explanation explain;

  @override
  State<DefinitionParagraph> createState() => _DefinitionParagraphState();
}

class _DefinitionParagraphState extends State<DefinitionParagraph>
    with ClickableTextStateMixin {
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
      TextSpan(
        children: [
          if (widget.explain.subscript != null)
            TextSpan(
              children: spans.getRange(0, firstSpan.length).toList(),
              style: textTheme.bodyLarge!.apply(color: colorScheme.primary),
            ),
          TextSpan(
            children: spans.getRange(firstSpan.length, spans.length).toList(),
            style: textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
        ],
      ),
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
        Text(
          definition.partOfSpeech,
          style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ).coloredSpeech(context: context),
        if (definition.phoneticUk != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇬🇧${definition.phoneticUk!}', style: textTheme.bodyLarge),
              PlatformWidgetBuilder(
                material: (_, child, __) => InkWell(
                  onTap: playPhonetic(
                    definition.audioUk,
                    word: word,
                    gTTs: gTTS.UK,
                  ),
                  child: child,
                ),
                cupertino: (_, child, __) => GestureDetector(
                  onTap: playPhonetic(
                    definition.audioUk,
                    word: word,
                    gTTs: gTTS.UK,
                  ),
                  child: child,
                ),
                child: Icon(
                  CupertinoIcons.volume_up,
                  size: textTheme.bodyLarge!.fontSize,
                ),
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
                  child: child,
                ),
                cupertino: (_, child, __) => GestureDetector(
                  onTap: playPhonetic(definition.audioUs, word: word),
                  child: child,
                ),
                child: Icon(
                  CupertinoIcons.volume_up,
                  size: textTheme.bodyLarge!.fontSize,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
